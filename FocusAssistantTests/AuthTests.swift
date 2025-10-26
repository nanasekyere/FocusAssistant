import Testing
@testable import FocusAssistant
import Foundation

// MARK: - Protocol seams for fakes (scoped to tests only)
private protocol AuthLike {
    func currentUser() -> FakeUser?
    func signIn(email: String, password: String) async throws -> FakeUser
    func createUser(email: String, password: String) async throws -> FakeUser
    func signOut() throws
}

private protocol FirestoreLike {
    func setUser(_ user: User) async throws
    func getUser(uid: String) async throws -> User
}

// Minimal user representation for fakes
private struct FakeUser: Equatable { let uid: String }

// MARK: - Fakes
private final class FakeAuth: AuthLike {
    var storedUser: FakeUser?
    var signInError: Error?
    var createError: Error?
    var signOutError: Error?

    func currentUser() -> FakeUser? { storedUser }

    func signIn(email: String, password: String) async throws -> FakeUser {
        if let err = signInError { throw err }
        let u = FakeUser(uid: "signed-in-uid")
        storedUser = u
        return u
    }

    func createUser(email: String, password: String) async throws -> FakeUser {
        if let err = createError { throw err }
        let u = FakeUser(uid: "created-uid")
        storedUser = u
        return u
    }

    func signOut() throws {
        if let err = signOutError { throw err }
        storedUser = nil
    }
}


private final class FakeStore: FirestoreLike {
    var users: [String: User] = [:]
    var setError: Error?
    var getError: Error?

    @MainActor func setUser(_ user: User) async throws {
        if let err = setError { throw err }
        users[user.id] = user
    }

    func getUser(uid: String) async throws -> User {
        if let err = getError { throw err }
        if let u = users[uid] { return u }
        throw NSError(domain: "FakeStore", code: 404)
    }
}

// MARK: - A thin wrapper around DataManager to inject fakes
// We can subclass and override the Firebase-interacting methods in tests.
private final class TestableDataManager: DataManager {
    private let auth: AuthLike
    private let store: FirestoreLike

    init(auth: AuthLike, store: FirestoreLike) {
        self.auth = auth
        self.store = store
        super.init()
    }

    // Helpers to bridge to production API surface
    override func checkCurrentUser() {
        // simulate reading current user then fetching
        if let u = auth.currentUser() {
            self.userSession = nil // not used in tests, but keep parity
            Task { await self.fetchUserOverride(uid: u.uid) }
        }
    }

    // Provide test-only overrides to avoid real Firebase
    func signInTest(email: String, password: String) async {
        do {
            let user = try await auth.signIn(email: email, password: password)
            await fetchUserOverride(uid: user.uid)
            self.alertError = nil
        } catch {
            self.alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .auth, action: .signIn))
        }
    }

    func createUserTest(email: String, password: String, fullname: String) async {
        do {
            let user = try await auth.createUser(email: email, password: password)
            let new = User(id: user.uid, fullName: fullname, email: email)
            try await store.setUser(new)
            await fetchUserOverride(uid: user.uid)
            self.alertError = nil
        } catch {
            self.alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .auth, action: .signUp))
        }
    }

    func signOutTest() {
        do {
            try auth.signOut()
            self.userSession = nil
            self.currentUser = nil
            self.alertError = nil
        } catch {
            self.alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .auth, action: .signOut))
        }
    }

    @MainActor
    private func fetchUserOverride(uid: String) async {
        if let fetched = try? await store.getUser(uid: uid) {
            self.currentUser = fetched
        }
    }
}

@Suite("AuthVM tests")
struct AuthTests {
    @MainActor @Test("Successful sign in populates currentUser and clears error")
    func signInSuccess() async throws {
        let auth = FakeAuth()
        let store = FakeStore()
        // Preload a user in the store to simulate existing profile
        let existing = User(id: "signed-in-uid", fullName: "Ada Lovelace", email: "ada@example.com")
        store.users[existing.id] = existing

        let vm = TestableDataManager(auth: auth, store: store)
        await vm.signInTest(email: "ada@example.com", password: "correct-horse")

        #expect(vm.currentUser?.id == existing.id)
        #expect(vm.alertError == nil)
        #expect(vm.showingAlert == false)
    }

    @MainActor @Test("Sign in failure sets error state")
    func signInFailure() async throws {
        let auth = FakeAuth()
        auth.signInError = NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])        
        let store = FakeStore()
        let vm = TestableDataManager(auth: auth, store: store)

        await vm.signInTest(email: "ada@example.com", password: "wrong")

        #expect(vm.currentUser == nil)
        #expect(vm.showingAlert == true)
        #expect(vm.alertError != nil)
        if case .dataManagerError(let error) = vm.alertError {
            #expect(error.errorDescription?.contains("sign in") == true)
        }
    }

    @MainActor @Test("Create user writes to store and fetches currentUser")
    func createUserSuccess() async throws {
        let auth = FakeAuth()
        let store = FakeStore()
        let vm = TestableDataManager(auth: auth, store: store)

        await vm.createUserTest(email: "grace@example.com", password: "password", fullname: "Grace Hopper")

        #expect(vm.currentUser?.email == "grace@example.com")
        #expect(store.users["created-uid"]?.fullName.contains("Grace") == true)
        #expect(vm.alertError == nil)
        #expect(vm.showingAlert == false)
    }

    @MainActor @Test("Create user failure sets error state")
    func createUserFailure() async throws {
        let auth = FakeAuth()
        auth.createError = NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email already in use"])
        let store = FakeStore()
        let vm = TestableDataManager(auth: auth, store: store)

        await vm.createUserTest(email: "duplicate@example.com", password: "password", fullname: "Test User")

        #expect(vm.currentUser == nil)
        #expect(vm.showingAlert == true)
        #expect(vm.alertError != nil)
        if case .dataManagerError(let error) = vm.alertError {
            #expect(error.errorDescription?.contains("sign up") == true)
        }
    }

    @MainActor @Test("Sign out clears session and user")
    func signOutClearsState() async throws {
        let auth = FakeAuth()
        let store = FakeStore()
        // Seed a user
        let seeded = User(id: "signed-in-uid", fullName: "Test User", email: "t@example.com")
        store.users[seeded.id] = seeded
        let vm = TestableDataManager(auth: auth, store: store)
        await vm.signInTest(email: "t@example.com", password: "ok")
        #expect(vm.currentUser != nil)

        vm.signOutTest()

        #expect(vm.currentUser == nil)
        #expect(vm.alertError == nil)
    }

    @MainActor @Test("Sign out failure sets error state")
    func signOutFailure() async throws {
        let auth = FakeAuth()
        auth.signOutError = NSError(domain: "Auth", code: 500, userInfo: [NSLocalizedDescriptionKey: "Sign out failed"])
        let store = FakeStore()
        // Seed a user
        let seeded = User(id: "signed-in-uid", fullName: "Test User", email: "t@example.com")
        store.users[seeded.id] = seeded
        let vm = TestableDataManager(auth: auth, store: store)
        await vm.signInTest(email: "t@example.com", password: "ok")
        #expect(vm.currentUser != nil)

        vm.signOutTest()

        // User should still be there since sign out failed
        #expect(vm.currentUser != nil)
        #expect(vm.showingAlert == true)
        #expect(vm.alertError != nil)
        if case .dataManagerError(let error) = vm.alertError {
            #expect(error.errorDescription?.contains("sign out") == true)
        }
    }
}

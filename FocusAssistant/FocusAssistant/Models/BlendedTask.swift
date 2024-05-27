//
//  BlendedTask.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//

import Foundation
import SwiftData
import UserNotifications

@Model class BlendedTask: TaskProtocol {
    var identity: UUID = UUID()
    var name: String = ""
    var duration: Int = 1500
    var priority: Priority = Priority.low
    var imageURL: String?
    var details: String?
    var isCompleted: Bool = false

    var pomodoroCounter: Int = 0
    var isBreak: Bool = false
    // Relationship to subtasks with cascade delete rule
    @Relationship(deleteRule: .cascade, inverse: \Subtask.blendedTask)
    var subtasks = [Subtask]()

    // Computed property to get sorted subtasks by index
    var sortedSubtasks: [Subtask] {
        return subtasks.sorted(by: { $0.index < $1.index })
    }

    init(name: String, duration: Int, priority: Priority, imageURL: String? = nil, details: String? = nil, subtasks: [Subtask]) {
        self.name = name
        self.duration = duration
        self.priority = priority
        self.imageURL = imageURL
        self.details = details
        self.subtasks = subtasks
    }

    func scheduleNotification() {
        print("noti")
    }

    func descheduleNotification() {
        print("no noti")
    }

    func completeTask() {
        if isBreak {
            isBreak = false
            duration = 1500
            // Schedule next interval here
            return
        }

        pomodoroCounter += 1

        if pomodoroCounter == 4 {
            isCompleted = true
            pomodoroCounter = 0
        } else {
            isBreak = true
            duration = 300
        }
    }
}

/// Represents a subtask within a blended task.
@Model class Subtask {
    var name: String // Name of the subtask

    // Relationship to details with cascade delete rule
    @Relationship(deleteRule: .cascade, inverse: \Detail.subtask)
    var details = [Detail]()

    // Computed property to get sorted details by index
    var sortedDetails: [Detail] {
        return details.sorted(by: { $0.index < $1.index })
    }

    var index: Int // Index of the subtask in the parent BlendedTask
    var blendedTask: BlendedTask? // Reference to the parent BlendedTask

    // Initializer to create a Subtask with name, details, and index
    init(name: String, details: [Detail], index: Int) {
        self.name = name
        self.details = details
        self.index = index
    }

    // Initializer to create a Subtask from a DummySubtask
    init(from dummySubtask: DummySubtask, index: Int) {
        self.name = dummySubtask.name
        self.details = []
        self.index = index
    }
}

/// Represents a detail within a subtask.
@Model class Detail {
    var desc: String // Description of the detail
    var isCompleted: Bool // Flag to indicate if the detail is completed
    var subtask: Subtask? // Reference to the parent Subtask
    var index: Int = 0 // Index of the detail in the parent Subtask

    // Initializer to create a Detail with description, completion status, and index
    init(desc: String, isCompleted: Bool, index: Int) {
        self.desc = desc
        self.isCompleted = isCompleted
        self.index = index
    }

    // Initializer to create a Detail from a DummyDetail
    init(from dummyDetail: DummyDetail, index: Int) {
        self.desc = dummyDetail.desc
        self.isCompleted = dummyDetail.isCompleted
        self.index = index
    }
}

/// Codable struct to represent a dummy task with a name and subtasks.
struct DummyTask: Codable {
    var name: String
    var subtasks = [DummySubtask]()

    private enum CodingKeys: String, CodingKey {
        case name, subtasks
    }

    // Initializer for creating a DummyTask
    init(name: String, subtasks: [DummySubtask]) {
        self.name = name
        self.subtasks = subtasks
    }

    // Initializer to decode a DummyTask from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        subtasks = try container.decodeIfPresent([DummySubtask].self, forKey: .subtasks) ?? []
    }

    // Function to encode a DummyTask to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(subtasks, forKey: .subtasks)
    }

    // Initializer to create a DummyTask from Data
    init(data: Data) throws {
        let me = try JSONDecoder().decode(DummyTask.self, from: data)
        self.init(name: me.name, subtasks: me.subtasks)
    }

    // Initializer to create a DummyTask from a JSON string
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
}

/// Codable struct to represent a dummy subtask with a name and details.
struct DummySubtask: Codable, Hashable {
    var name: String
    var details = [DummyDetail]()

    // Initializer for creating a DummySubtask
    init(name: String) {
        self.name = name
        self.details = []
    }

    private enum CodingKeys: String, CodingKey {
        case name, details
    }

    // Initializer to decode a DummySubtask from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        details = try container.decodeIfPresent([DummyDetail].self, forKey: .details) ?? []
    }

    // Function to encode a DummySubtask to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(details, forKey: .details)
    }

    // Equatable conformance to compare two DummySubtasks
    static func == (lhs: DummySubtask, rhs: DummySubtask) -> Bool {
        return lhs.name == rhs.name && lhs.details == rhs.details
    }

    // Hashable conformance to hash a DummySubtask
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(details)
    }
}

/// Codable struct to represent a dummy detail with a description and completion status.
struct DummyDetail: Codable, Equatable, Hashable {
    var desc: String
    var isCompleted: Bool

    // Initializer for creating a DummyDetail
    init(desc: String) {
        self.desc = desc
        self.isCompleted = false
    }

    private enum CodingKeys: String, CodingKey {
        case desc
        case isCompleted
    }

    // Initializer to decode a DummyDetail from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        desc = try container.decode(String.self, forKey: .desc)
        isCompleted = false
    }

    // Function to encode a DummyDetail to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(desc, forKey: .desc)
        try container.encode(isCompleted, forKey: .isCompleted)
    }

    // Equatable conformance to compare two DummyDetails
    static func == (lhs: DummyDetail, rhs: DummyDetail) -> Bool {
        return lhs.desc == rhs.desc && lhs.isCompleted == rhs.isCompleted
    }

    // Hashable conformance to hash a DummyDetail
    func hash(into hasher: inout Hasher) {
        hasher.combine(desc)
        hasher.combine(isCompleted)
    }
}
let mockJSON = """
 {
   "name": "Make a salad",
   "subtasks": [
     {
       "name": "Prepare the vegetables",
       "details": [
         {
           "desc": "Wash the lettuce",
           "isCompleted": false
         },
         {
           "desc": "Chop the tomatoes",
           "isCompleted": false
         },
         {
           "desc": "Slice the cucumbers",
           "isCompleted": false
         },
         {
           "desc": "Dice the bell peppers",
           "isCompleted": false
         }
       ]
     },
     {
       "name": "Prepare the dressing",
       "details": [
         {
           "desc": "Mix olive oil and vinegar",
           "isCompleted": false
         },
         {
           "desc": "Add salt and pepper",
           "isCompleted": false
         },
         {
           "desc": "Whisk until well combined",
           "isCompleted": false
         }
       ]
     },
     {
       "name": "Combine the ingredients",
       "details": [
         {
           "desc": "Place the prepared vegetables in a large bowl",
           "isCompleted": false
         },
         {
           "desc": "Drizzle the dressing over the vegetables",
           "isCompleted": false
         },
         {
           "desc": "Toss the salad until the dressing is evenly distributed",
           "isCompleted": false
         }
       ]
     },
     {
       "name": "Serve the salad",
       "details": [
         {
           "desc": "Transfer the salad to a serving dish",
           "isCompleted": false
         },
         {
           "desc": "Garnish with fresh herbs (optional)",
           "isCompleted": false
         }
       ]
     }
   ]
 }
 """

let mockJSON2 = """
{
  "name": "Write a movie analysis",
  "subtasks": [
    {
      "name": "Watch the movie",
      "details": [
        {
          "desc": "Select the movie to analyze",
          "isCompleted": false
        },
        {
          "desc": "Find a quiet and comfortable place to watch",
          "isCompleted": false
        },
        {
          "desc": "Take notes while watching the movie",
          "isCompleted": false
        }
      ]
    },
    {
      "name": "Analyze the plot",
      "details": [
        {
          "desc": "Summarize the main storyline",
          "isCompleted": false
        },
        {
          "desc": "Identify key plot points and turning points",
          "isCompleted": false
        },
        {
          "desc": "Analyze the character arcs",
          "isCompleted": false
        }
      ]
    },
    {
      "name": "Analyze the themes",
      "details": [
        {
          "desc": "Identify the main themes of the movie",
          "isCompleted": false
        },
        {
          "desc": "Explore how the themes are developed throughout the movie",
          "isCompleted": false
        },
        {
          "desc": "Consider the deeper messages and symbolism",
          "isCompleted": false
        }
      ]
    },
    {
      "name": "Analyze the cinematography",
      "details": [
        {
          "desc": "Evaluate the use of camera angles and shots",
          "isCompleted": false
        },
        {
          "desc": "Consider the lighting and color schemes",
          "isCompleted": false
        },
        {
          "desc": "Analyze the use of visual effects and editing",
          "isCompleted": false
        }
      ]
    },
    {
      "name": "Write the analysis",
      "details": [
        {
          "desc": "Organize the analysis into an outline",
          "isCompleted": false
        },
        {
          "desc": "Write an introduction, body, and conclusion",
          "isCompleted": false
        },
        {
          "desc": "Incorporate evidence and examples from the movie",
          "isCompleted": false
        }
      ]
    },
    {
      "name": "Edit and revise",
      "details": [
        {
          "desc": "Review the analysis for clarity and coherence",
          "isCompleted": false
        },
        {
          "desc": "Check for grammar and spelling errors",
          "isCompleted": false
        },
        {
          "desc": "Revise as needed for a polished final draft",
          "isCompleted": false
        }
      ]
    }
  ]
}
"""

//  This file was automatically generated and should not be edited.

import Apollo

public final class ExampleQuery: GraphQLQuery {
  public let operationDefinition =
    "query Example {\n  sound(id: 5) {\n    __typename\n    id\n    latitude\n    longitude\n    user {\n      __typename\n      id\n      email\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sound", arguments: ["id": 5], type: .object(Sound.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sound: Sound? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "sound": sound.flatMap { (value: Sound) -> ResultMap in value.resultMap }])
    }

    /// returns the queried sound
    public var sound: Sound? {
      get {
        return (resultMap["sound"] as? ResultMap).flatMap { Sound(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "sound")
      }
    }

    public struct Sound: GraphQLSelectionSet {
      public static let possibleTypes = ["SoundType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .scalar(Double.self)),
        GraphQLField("longitude", type: .scalar(Double.self)),
        GraphQLField("user", type: .nonNull(.object(User.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, latitude: Double? = nil, longitude: Double? = nil, user: User) {
        self.init(unsafeResultMap: ["__typename": "SoundType", "id": id, "latitude": latitude, "longitude": longitude, "user": user.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var latitude: Double? {
        get {
          return resultMap["latitude"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double? {
        get {
          return resultMap["longitude"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "longitude")
        }
      }

      public var user: User {
        get {
          return User(unsafeResultMap: resultMap["user"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "user")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes = ["UserType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("email", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, email: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "UserType", "id": id, "email": email])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var email: String? {
          get {
            return resultMap["email"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "email")
          }
        }
      }
    }
  }
}
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Defines the app's knowledge of the model's class labels.
*/

extension ActionClassifier {
    /// Represents the app's knowledge of the Exercise Classifier model's labels.
    enum Label: String, CaseIterable {
        case jump = "jump"
        case stand = "stand"
        case walk = "walk"
//        case walkF = "walkF"
//        case walkFL = "walkFL"
//        case walkFR = "walkFR"
//        case walkL = "walkL"
//        case walkR = "walkR"
        case run = "run"
        case squat = "squat"

        /// Creates a label from a string.
        /// - Parameter label: The name of an action class.
        init(_ string: String) {
            guard let label = Label(rawValue: string) else {
                let typeName = String(reflecting: Label.self)
                fatalError("Add the `\(string)` label to the `\(typeName)` type.")
            }

            self = label
        }
    }
}

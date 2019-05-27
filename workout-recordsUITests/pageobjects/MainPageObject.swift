import XCTest

extension XCUIElement {
    func clear() {
        if !self.isEnabled { return }
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
    
    func clearAndEnter(_ newText: String) {
        if !self.isEnabled { return }
        self.clear()
        self.typeText(newText)
    }
    
    func oneUp() {
        if !self.isEnabled { return }
        let startCoord = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -35.0))
        endCoord.tap()
        sleep(1)
    }
}

class MainPageObject {
    private let app: XCUIApplication
    private let test: XCTestCase
    
    private let exist = NSPredicate(format: "exists == TRUE")
    private let notExist = NSPredicate(format: "exists == FALSE")
    private let enabled = NSPredicate(format: "enabled == TRUE")
    
    private let deleteWorkoutTitle = "Delete workout?"
    
    init(_ app: XCUIApplication, _ test: XCTestCase) {
        self.app = app
        self.test = test
    }
    
    private func getActivityButton() -> XCUIElement { return app.buttons["activity"] }
    private func getActivitySelect() -> XCUIElement { return app.buttons["activity_select"] }
    private func getActivityClose() -> XCUIElement { return app.buttons["activity_close"] }
    func getDistanceField() -> XCUIElement { return app.textFields["distance"] }
    private func getCaloriesField() -> XCUIElement { return app.textFields["calories"] }
    func getRecordButton() -> XCUIElement { return app.buttons["Record"] }
    
    static func formatDateTime(_ date: Date) -> String {
        return String(WRFormat.formatDate(date).prefix(16))
    }
    
    static func formatDateHour(_ date: Date) -> String {
        return String(WRFormat.formatDate(date).prefix(14))
    }
    
    func assertWorkout(_ index: Int, _ datePrefix: String, _ duration: String,
                       _ distance: String, _ calories: String) {
        let wopo = WorkoutPageObject(getWorkoutCell(index))
        XCTAssertTrue(wopo.getDate().starts(with: datePrefix), "date mismatch (expected prefix / actual date)\n\(datePrefix)\n\(wopo.getDate())")
        XCTAssertEqual(wopo.getDuration(), duration)
        XCTAssertEqual(wopo.getDistance(), distance)
        XCTAssertEqual(wopo.getCalories(), calories)
    }
    
    func getWorkout(_ index: Int) -> WorkoutPageObject {
        return WorkoutPageObject(getWorkoutCell(index))
    }
    
    func createWorkout(activity: String, setNow: Bool = false,
                       _ date: (daysPast: Int, hour: Int, min: (Int))? = nil,
                       duration: (Int, Int)? = nil,
                       distance: Double? = nil,
                       calories: Int? = nil) {
        selectActivity(activity)
        if setNow {
            app.textFields["date"].tap()
            app.buttons["Now"].tap()
            tapDone()
        }
        if let date = date {
            app.textFields["date"].tap()
            for _ in 1...date.daysPast {
                app.pickerWheels.element(boundBy: 0).oneUp()
            }
            app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: String(date.hour))
            app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: String(date.min))
            tapDone()
        }

        if let duration = duration {
            app.textFields["duration"].tap()
            app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: String(duration.0))
            app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: String(duration.1))
            tapDone()
        }

        let distanceField = getDistanceField()
        if distanceField.isEnabled {
            if let distance = distance {
                distanceField.clearAndEnter(String(distance))
            } else {
                distanceField.clear()
            }
            tapDone()
        }

        let caloriesField = getCaloriesField()
        if caloriesField.isEnabled {
            if let calories = calories {
                caloriesField.clearAndEnter(String(calories))
            } else {
                caloriesField.clear()
            }
            tapDone()
        }

        getRecordButton().tap()
        let recBtnEnabled = test.expectation(for: enabled, evaluatedWith: app.buttons["Record"])
        test.wait(for: [ recBtnEnabled ], timeout: 5)
    }
    
    func selectActivity(_ activity: String) {
        getActivityButton().tap()
        let activityOpen = test.expectation(for: exist, evaluatedWith: getActivitySelect())
        test.wait(for: [ activityOpen ], timeout: 5)
        app.staticTexts[activity].tap()
        getActivitySelect().tap()
        XCTAssertEqual(getActivityButton().label, activity)
    }
    
    func workoutCount() -> Int {
        return app.tables.children(matching: .cell).count - 1
    }
    
    func deleteAllRecords() {
        while workoutCount() > 0 {
            deleteWorkoutRecord(0)
        }
    }
    
    func hasWorkoutRecord() -> Bool {
        return getWorkoutCell(0).exists
    }
    
    func deleteWorkoutRecord(_ index: Int, _ dialogText: [String]? = nil) {
        let cell = getWorkoutCell(index)
        cell.swipeLeft()
        cell.buttons["Delete"].tap()
        waitFor(alertTitle: deleteWorkoutTitle, to: exist)
        let alert = getAlert(deleteWorkoutTitle)
        if let expectedDialog = dialogText {
            let text = alert.staticTexts.element(boundBy: 1).label
            for expected in expectedDialog {
                XCTAssertTrue(text.contains(expected), "Dialog text assertion (expected / dialog-text)\n\(expected)\n\(text)")
            }
        }
        alert.buttons["Delete"].tap()
        waitFor(alertTitle: deleteWorkoutTitle, to: notExist)
    }
    
    func showMore() {
        app.buttons["showMore"].tap()
    }
    
    func getDistanceValue() -> String {
        return getDistanceField().value as! String
    }
    
    func sendToDistanceField(_ keys: [String]) {
        keysIntoField(getDistanceField(), keys: keys)
    }
    
    func clearDistanceField() {
        getDistanceField().clear()
    }
    
    func getCaloriesValue() -> String {
        return getCaloriesField().value as! String
    }
    
    func sendToCaloriesField(_ keys: [String]) {
        keysIntoField(getCaloriesField(), keys: keys)
    }
    
    func clearCaloriesField() {
        getCaloriesField().clear()
    }
    
    private func keysIntoField(_ field: XCUIElement, keys: [String]) {
        field.tap()
        for key in keys {
            app.keys[key].tap()
        }
        tapDone()
    }
    
    private func getWorkoutCell(_ index: Int) -> XCUIElement {
        return app.cells.element(matching: .cell, identifier: "WorkoutTableCell_\(index)")
    }
    
    private func tapDone() { app.buttons["Done"].tap() }
    private func getAlert(_ title: String) -> XCUIElement { return app.alerts[title] }
    
    private func waitFor(alertTitle title: String, to predicate: NSPredicate) {
        let alert = test.expectation(for: predicate, evaluatedWith: getAlert(title))
        test.wait(for: [ alert ], timeout: 5)
    }
}

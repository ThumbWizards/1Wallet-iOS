# Timeless-SwiftUI MVVM Architecture

##### Core concepts of MVVM architecture: 
- MVVM is the software architecture pattern in which we can decouple UI related code and business logic. 
- It provides better decoupling of the UI and business logic. 
- This decoupling results in thin, flexible and easy-to-read controller classes in iOS. 
- It provides better encapsulation. Business logic and workflows are contained almost exclusively in the view models. 

![alt text](https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/MVVMPattern.png/500px-MVVMPattern.png)

##### Roles and Responsibilities:
&nbsp;
**View Model:**

- The View Model is at the heart of the MVVM design pattern and provides the connection between model and view.
- View model is full data representation of the view. It receives UI events and performs business logic and provides the output to be displayed on the UI. 
- To be able to bind values from our view Model to our view, we can use @ObservableObject or @StateObject.
- Observable Object synthesises an objectWillChange publisher that emits the changed value before any of its @Publisher properties changes. 
- All the mutating variables are mark as publisher stored in view Model. Every key value change in published property will refresh view body automatically. It leads to appear new data every time in view body.
> Sometimes adding more @Published variables leads performance issues. The best practice is to use @Published variable is to add only data models for the view representative. (e.g. arrays, objects etc...)

**View:**
- View is only responsible for UI related things like show and get information. 
- View contains little or no business logic and is primarily responsible to the view model to configure and present UI element. 
- View has separate view model variable with data type Observable Object where all the state change variables are stored. Every object change will trigger view refresh and fetches new data from view Model. 

**Model:**
- The MVVM data model is a class that declares properties for managing business data. E.g., User Model. 
- This is only your model, nothing much here. It’s the same model as in MVC. It is used by view Model and updates whenever view Model sends new updates. 

##### File Structure: 
- AppConstant 
    - All the scheme level constants are placed here. e.g. serverUrl, apiKey etc... 
- Resources 
    - Resources folder contains folder for storing mp4/mp3 files, image/gif files, fonts, timezone json files, 3D models. The Resources folder can contain more or less folders.
- Model
    - LoginModel 
    - UserModel
- Services
    - It contains all the top level singleton service classes like Cloudinary, TansferTransaction, StreamChat etc...
- Module name (E.g., Authentication module) 
    - View 
        - LoginView 
        - SignupView 
    - ViewModel 
        - LoginView+ViewModel
        - SignupView+ViewModel
- Reusables 
    - Components and utilities that:
        - Don’t belong to a specific scene
        - Aren’t meriting if their own top-level folder group 
        - Aren’t specifically tied to a sub-group of any top-level folder group
- Network Layer
    - Utilities and services for networking and API interfacing.
- Chat
    - We use StreamChat SDK for chat module. This group contains all the chat related stuffs.

##### File Naming Convention: 
&nbsp;

Name  | ViewModel | View
------------- | -------------| -------------
Convention   | <EntityName>ViewModel | <EntityName>View 
Example 1   | ShellView+ViewModel | ShellView 
Example 2    | TabView+ViewModel  | TabView  

##### Code quality:
- Code syntax must match with SwiftLint pre-defined rules. All the warnings should be avoided.

##### Package Management:
- All the external dependencies are bind with cocoa-pods and SPM.

##### Other files and their responsibilities:

###### Constants:
- `Constants` group contains sub-group of individuals modules constants file.
- All the application level constants should be placed here.

###### ASSettings:
- ASSettings file contains all the userDefault key and its default value.

###### Reusables:
- Components and utilities that are used in multiple screens.

###### Extensions:
- All type of extensions are placed here with individual sub-groups.

###### Scenes:
- All application views and its viewModel are placed here with individual sub-groups.

##### How view model would handle multiple states scenario and complex use case?
- In viewModel, state and binding are represented as published variable. 
- All the multiple states will appear at viewModel. 
- In terms of complex use case, all the data flow will be done by single view model and its published variables. So, no need to take care of anything. 

##### How can we achieve unidirectional data flow instead of two-way bindings in case of complex UI?
- In SwiftUI, we can’t achieve unidirectional data flow instead of two-way bindings.
- All the state and binding variables are tightly coupled with view and every variable change led to view body change. 

##### What if our view model becomes bigger and there are a lot of nested child views? 
- Parent view has its own view model. All the data flow will be done by single view model. 
- All child view has reference of viewModel and fetch data what it needs. 
- In SwiftUI, nested child views have some problem. By nested child views, there may be so many published (State/bind) variables in viewModel. Every single variable change will lead to refresh parent view and all its nested views. 
- Increasing nested child views in parent view puts in danger some times. Coz, UI refresh takes some time and leads to performance issue. 

##### How to make a shared class?
- The singleton pattern guarantees that only one instance of a class is instantiated.
- A few years ago, Swift introduced static properties and access control to the language. This opened up an alternative approach to implementing the singleton pattern in Swift. It's much cleaner and elegant then using a global variable.

```Swift
class NetworkManager {
    // MARK: - Properties
    static let shared = NetworkManager(baseURL: API.baseURL)
    let baseURL: URL
    
    // Initialisation
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
```

##### Best practices:
1. UserDefault vs ASSettings & appStorage
    - All the userdefault key and default value should be added in ASSettings like this:
    ```Swift
        static var isUsingTwentyFourFormat = ASSettingItem(key: "general-settings-is-using-twenty-four-hour-time", defaultValue: false)
    ```
    - ASSettings contains all the userdefaults key and its default value. For any new userDefault key you can create key-value variable here in this structure.
    - Do not use Swift's Userdefault function to fetch data from preferences, use @AppStorage instead.
2. Usage of @State and @Published properties
    - Animation and view rendering related mutable variables should be placed in view using @State properties.
    - @Published variable should be used only for variables which are responsible for triggering UI refresh and data flow. (e.g. arrays, object etc...) and should be added in relevant viewModel.

    
3. Make sure to modify State/Published variables in main thread. Which are responsible for UI rendering. Modifying these properties on background or any other threads can result in weird behaviours.
4. @StateObject vs @ObservableObject
    - @StateObject ensures that it initialise before body call. It has single reference copy like singleton object.
    - @ObservableObject using shared class and @StateObject behaves same. Both has single source of copy.
    - You can declare shared @observableObject is like this:
    
    ```Swift
    extension AvailabilitySettingsViewModel {
        static let shared = AvailabilitySettingsViewModel()//@ObservableObject
    }
    ```

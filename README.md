# SwiftUIComponents

This is a Package contains the Swiftui Components. All the components can be used in iOS and macOS applications.

SwiftUI Designer is a tool to create SwiftUI applications for iOS and macOS platforms based on a set of custom components which can be configured. The application provides a Code Generator to create SwiftUI code that can be easely included in your Xcode project.

All components are highly configurable and include a standard behavior. For example, the List is able to add, delete, update and select items without write any code.

Supported components are:
    
- **Menu**: this is left side menu through which either show a view in the right side or activate action. Once you have configured the menu's look and feel and generated the code, you have only to provide your Views associated at each menu item and your custom code for each action in the menu. Menu also provides an optional right side inspector where you can add additional information or user interaction.

- **List**: this component is a list of items which alredy provides the basic operations like adding a new item, editing an existing item and deleting an item. The look and feel is highly customizable and custom actions can be added to each item to perform custom operations.

- **Navigation List**: provides the same features of the List but also allows to show the detail of each item. This component can be used when the items have many details that do not fit in the list's row.

- **Tab Bar**: component which allows to easily switch between either views or components selecting one of them in the tab bar. The selection bar can appear at the top of the screen or at the bottom and has an highly customizable look and feel.

All the components can be also configured at run-time and they react to the changes (e.g. menu items can be dynamically added/removed).

- **ToDo**:

    - Support for WatchOS
    - Additional global actions for lists
    - Callbacks to enable and disable menu items
    - Callbacks to enable and disable list actions and navigation list actions

- **Known Issues**:

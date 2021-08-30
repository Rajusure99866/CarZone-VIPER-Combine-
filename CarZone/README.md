# "CARZONE - IOS Application"
## _This Project is build using most powerfull VIPER architecture and COMBINE Framwork to unleash the power of Reactive programming and Clean architecture._

VIPER:
    
# Modules
1. List Module
2. Network
3. Service
4. Helpers for Navigation, URL request


# List Module: This is a common module used for both manufacturer and models list screen. This module depends completey on what type of list(Manufacturer or Models) that we want to represent.

## List Router: Application starts from router and then initialises the view controller, presenter, interacter with dependencies.


## List Presenter: It controls the List Interacter, List Router, list View and passes information between interacter, router and view.

## List Interactor: Makes the API request thorugh Network module and sends the data to its subcriber.


## List View: loads the table view for the list type and sends the input signals to registered subcribers.


# Executed XCTest cases for presenter and service request.










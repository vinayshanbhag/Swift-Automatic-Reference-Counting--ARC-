//: Automatic Reference Counting in Swift Playground

// Swift uses Automatic Reference Counting for memory management
// ARC free up memory automatically when class instances are no longer needed
// ARC applies to reference types (Classes, Closures) and not to value types (Structures & Enumerations)
//
// ARC needs more information when there is a strong reference cycle between instances
// e.g. Two class instances holding a reference to each other such that each one keeps the other alive
//
// Strong reference cycles may occur in class instances or closures
//
// Strong reference cycles in class instances with references to each other...
// Scenario 1: such that both can be nil. e.g.Person<->Apartment. Make one of the optional references weak
// Scenario 2: such that one may be nil and another cannot be nil.e.g. Person<->CreditCard. Make the non-optional reference unowned
// Scenario 3: such that both cannot be nil. e.g. Country<->CapitalCity. Make the non-optional reference unowned

// Scenario 1
class Person {
    let name:String
    var apartment:Apartment?
    
    init(name:String){ self.name = name }
    deinit{ print("deinit: Person named \(name), apartment \(apartment?.unit)") }
}

class Apartment {
    let unit:String
    weak var tenant:Person? // making this weak, breaks the strong reference cycle
    
    init(unit:String){ self.unit = unit }
    deinit{ print("deinit: Apartment unit \(unit), tenant \(tenant?.name)") }
}

var john: Person?
var unit1: Apartment?

john = Person(name: "John")
unit1 = Apartment(unit: "unit1")

john?.apartment = unit1
unit1?.tenant = john

john = nil // Strong reference from Apartment instance prevents removal of this instance
unit1 = nil // Strong reference from Person instance prevents removal of this instance


// Scenario 2
class Customer {
    let name: String
    var card:CreditCard?
    
    init(name:String){ self.name = name }
    deinit{ print("deinit: Customer named \(name), card \(card?.number)")}
}

class CreditCard {
    let number:String
    unowned var cardHolder:Customer // Making this unowned breaks the strong reference cycle.
    
    init(number:String, holder:Customer){ self.number = number; self.cardHolder = holder }
    deinit{ print("deinit: CreditCard number \(number) for card holder named \(cardHolder.name)") }
}

var johnny:Customer?
var card:CreditCard?

johnny = Customer(name: "John")
card = CreditCard(number: "1234 5678 9000 0000", holder: johnny!)

card = nil // Without marking the cardHolder as unowned - CreditCard instance stll has a strong reference to Customer. If cardHolder is unowned, card instance is released but john lives on
johnny = nil // Without marking the cardHolder as unowned - Customer instance still has a strong reference to CreditCard. If cardHolder is unowned, john is released and reference to card is decremented.


// Scenario 3
class Country {
    let name: String
    var capitalCity: City!
    
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
    deinit {
        print("deinit: Country named \(self.name)")
    }
}

class City {
    let name: String
    unowned let country: Country // marking this unowned breaks the strong reference cycle
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
    deinit {
        print("deinit: City named \(name)")
    }
}

var usa:Country? = Country(name: "USA", capitalName: "Washington D.C.")
usa = nil

// Strong reference cycles in closures

// User class has a greet property which is a closure returning a string. The closure refers to self.name creating 
// a strong reference to the User class, which in turn has a string reference to the closure
// A capture list is used to resolve such strong reference cycles
class User {
    var name:String
    
    //lazy var greet:()->String = {"Hello \(self.name)"} // No capture list. This results in a strong reference cycle
    lazy var greet:()->String = {[unowned self] in "Hello \(self.name)"} // greet is a closure that refers to User (self). And User has a strong reference to greet
    
    init(name:String){
        self.name = name
    }
    
    deinit {
        print("deinit: User named \(name)")
    }
}

var user:User? = User(name: "John")
user!.greet()
user = nil // Without a capture list, the strong reference cycle between User and closure greet, prevents deallocation of User instance.




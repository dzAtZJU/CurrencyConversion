## Constraint
### Specification
* Select from a list of currencies
* Enter amount
* See a list of exchange rates

* Data
    * List of Currencies
    * Currency <- ExchangeRate -> Currency

* Disk
* Network
    * Read Interval >= 30min

### Backend
* Parameter
    * source -> USD
    * currencies
* Response
    * timestamp
* Error Code
* Header
    * Etag + Date
* Server Internal
    * Refreshed every 60 mins
    
## Design
* Visual
    * Grid of exchange rates
        * Horizontal Scroll
        * Cell Size
            * Fixed Height
            * Fixed Width
- Cell Order
    * Recently 
    * Sort Alphabetically

* First Frame 

## Developer
### Arch
* Exchange Rates from USD to all other currencies
    * Network
    * Disk

* Foreground

* User Action
    * User
    * Verify Timestamp -> Network
        * UIX
            * ProgressHint
        * DataModel
            * Keep Amount
            * Update ExchangeRate

### Alg
* Amount * Memory(J -> X)
* MemoryCache (J -> X) 
    * J -> X = (USD -> X) / (USD -> J)
    * Clear when UA(Select Currency)
* Computing(String Process) -> Dictionary(“X”, USD -> X)
* URLCache
* Network

### Accuracy
* Max Data Age -> 30 min

### Feature Pool
State Restoration

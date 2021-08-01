import Cocoa

struct User{
    let name:String
    let id:Int
    
}

struct Ingrediants{
    let name:String
    let prepareTime:Int
}

struct Order{
    let user:User
    let ingrediants:[Ingrediants]
    var priorty:Int
    
}

struct Resource{
    let name:String
    var lock:NSLock = NSLock()
}

class Server{
    
    var lock:NSLock
    var orderList = [Order]()
    let recource:[Resource] = [Resource(name: "water"),Resource(name: "coffee"),Resource(name: "milk"),Resource(name: "suger")]
    var time:Timer!
    
    init() {
        lock = NSLock()
      //  pullRequest()
        timer()
        
    }
    
    func addOrder(_ order:Order){
        DispatchQueue.global().async {
            self.lock.lock()
            self.orderList.append(order)
            self.orderList.sort(by: {$0.priorty < $1.priorty})
           // print(self.orderList)
            self.lock.unlock()
        }
    }
    
    func pullRequest(){
        DispatchQueue.global().async {
            while true{
                self.handleOrder(self.orderList.removeFirst())
            }
        }
    }
    
    func timer(){
        time = Timer(timeInterval: 5, target: self, selector: #selector(decresePriorty), userInfo: nil, repeats: true)
    }
    
    @objc
    func decresePriorty(){
        for index in orderList.indices{
            orderList[index - 1].priorty -= 1
        }
        
    }
    
    func handleOrder(_ order:Order){
        var ingrediant = order.ingrediants.sorted(by: {$0.prepareTime > $1.prepareTime})
        while !ingrediant.isEmpty{
            self.getResources(ingrediant.removeFirst())
        }
        
        print("The order \(order.user.id) is ready :)")
    }
    
    func getResources(_ ingrediants:Ingrediants){
        for  resourceNeeded in recource{
            if ingrediants.name == resourceNeeded.name{
                guard resourceNeeded.lock.try() else {
                     return
                }
                    usleep(useconds_t(ingrediants.prepareTime))
                    resourceNeeded.lock.unlock()
            }
        }
    }
    
    
}


let user = User(name: "marah", id: 1)
let water = Ingrediants(name: "water", prepareTime: 2)
let coffee = Ingrediants(name: "coffee", prepareTime: 4)
let milk = Ingrediants(name: "milk", prepareTime: 3)
let suger = Ingrediants(name: "suger", prepareTime: 1)

let order1 = Order(user: user, ingrediants: [water,coffee], priorty: 0)
let order2 = Order(user: user, ingrediants: [water,coffee,milk], priorty: 0)
let order3 = Order(user: user, ingrediants: [water], priorty: 0)
let order4 = Order(user: user, ingrediants: [water,coffee,milk], priorty: 0)
let order5 = Order(user: user, ingrediants: [water,coffee], priorty: 0)
let order6 = Order(user: user, ingrediants: [water], priorty: 1)
let order7 = Order(user: user, ingrediants: [water,coffee], priorty: 2)
let order8 = Order(user: user, ingrediants: [water,coffee,milk], priorty: 3)

let server = Server()
server.addOrder(order1)
server.addOrder(order2)
server.addOrder(order3)
server.addOrder(order4)
server.addOrder(order5)
server.addOrder(order6)
server.addOrder(order7)
server.addOrder(order8)
server.pullRequest()





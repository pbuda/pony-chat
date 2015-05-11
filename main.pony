use "collections"

actor Main
  new create(env:Env) =>
    let server = Server(env)
    let c1 = Client("client1", server)
    c1.login()
    c1.post("Hi!")
    server.print_log()
    c1.logout()

class Client 
  let username:String
  let server:Server

  new create(username':String, server':Server) =>
    username = username'
    server = server'

  fun login() => server.login(username)

  fun logout() => server.logout(username)

  fun post(message:String) => server.post(username, username + ": " + message)

interface LogPrinter 
  be print(output:List[String] tag)

actor Server 
  let storage:Storage
  let sessions:Map[String, Session]
  let env:Env

  new create(env':Env) =>
    env = env'
    storage = MemoryStorage
    sessions = Map[String, Session]

  be login(username:String) =>
    try
      sessions.insert(username, Session(username, storage))
    end

  be logout(username:String) =>
    try
      sessions.remove(username)
    end

  be post(from:String, message:String) =>
    try
      sessions(from).post(from, message)
    end

  be print_log() =>
    storage.print(this)

  be print(output:List[String] tag) =>
    env.out.print("Output")

actor Session
  let username:String
  let storage:Storage

  new create(username':String, storage':Storage) =>
    username = username'
    storage = storage'

  be post(from:String, message:String) =>
    storage.push(message)

trait Storage tag
  be push(message:String)

  be print(printer:LogPrinter tag)

actor MemoryStorage is Storage 
  
  let log:List[String] = List[String]

  be push(message:String) => log.push(message)

  be print(printer:LogPrinter tag) =>
    printer.print(log)

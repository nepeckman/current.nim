import nerve/promises
when defined(js):
  const host = ""
else:
  const host = "http://127.0.0.1:1234"

import unittest, nerve, nerve/clientRuntime
import personService, greetingService, fileService

proc main() {.async.} =
  let personClient = PersonService.newHttpClient(host)
  let greetingClient = GreetingService.newHttpClient(host)
  let fileClient = FileService.newHttpClient(host)

  suite "Sanity":

    test "Hello":
      let msg = await personClient.hello("Nic")
      check(msg == "Hello Nic")
      let helloWorld = await personClient.hello()
      check(helloWorld == "Hello World")

    test "Add":
      let x = await personClient.add()
      let y = await personClient.add(1)
      let z = await personClient.add(2, 3)
      check(x == 0)
      check(y == 1)
      check(z == 5)

    test "Person":
      let person = await personClient.newPerson("Nic", 24)
      check(person.name == "Nic")

    test "Parent":
      let person = await personClient.newPerson("Alex", 32)
      let child = await personClient.newPerson("James", 4)
      let parent = await personClient.newParent(person, child)
      check(parent.self.name == "Alex")
      check(parent.children[0].name == "James")

    when defined(js):
      test "Error":
        expect RpcError:
          discard await fileClient.saveFile("missing.txt", "failure")

  suite "Proc arguments":

    test "Multiple defaults":
      let g1 = await greetingClient.greet()
      let g2 = await greetingClient.greet(name = "Nic")
      let g3 = await greetingClient.greet("Yo")
      let g4 = await greetingClient.greet("Goodday", "child")
      check(g1 == "Hello World")
      check(g2 == "Hello Nic")
      check(g3 == "Yo World")
      check(g4 == "Goodday child")

    test "No params":
      let msg = await personClient.helloWorld()
      check(msg == "Hello world")


when defined(js):
  discard main()
else:
  waitFor main()
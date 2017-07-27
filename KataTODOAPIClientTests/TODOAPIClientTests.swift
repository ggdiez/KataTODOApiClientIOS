
//
//  TODOAPIClientTests.swift
//  KataTODOAPIClient
//
//  Created by Pedro Vicente Gomez on 12/02/16.
//  Copyright © 2016 Karumi. All rights reserved.
//

import Foundation
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TODOAPIClientTests: NocillaTestCase {

    fileprivate let apiClient = TODOAPIClient()
    fileprivate let anyTask = TaskDTO(userId: "1", id: "2", title: "Finish this kata", completed: true)

    //GET
    
    func testShouldReturnsTheTasksOfItemsFromTODOsPath () {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .withHeaders(["Content-Type": "application/json", "Accept": "application/json"])?
            .andReturn(200)?
        .withBody(fromJsonFile("getTasksResponse"))
        
        var response: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { result in
            response = result
        }
        
        expect(response?.value?.count).toEventually(equal(200))
        assertTaskContainsExpectedValues((response?.value?[0])!)
    }
    
    
    func testShouldTreatExpecificServerResponse () {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(418)
        
        var response: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { result in
            response = result
        }
        expect(response?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 418)))
    }
    
    func testShouldReturnTheCorrectTaskID () {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(200)?
            .withBody(fromJsonFile("getTasksByIdResponse"))
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (result) in
            response = result
        }
        
        expect(response).toEventuallyNot(beNil())
    }
    
    
    func testReturnItemNotFound () {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(404)
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (result) in
            response = result
        }
        
        expect(response?.error).toEventually(equal(TODOAPIClientError.itemNotFound))
    }
    
    func testReturnItemOk () {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(200)?
            .withBody(fromJsonFile("getTasksByIdResponse"))
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (result) in
            response = result
        }
        
        expect(response).toEventuallyNot(beNil())
    }
    
    //POST
    
    func testShouldReturnOkWhenCreateATask () {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .withBody(fromJsonFile("addTaskToUserRequest"))?
            .andReturn(201)
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "Finish this kata", completed: false) { result in
            response = result
        }
        
        expect(response).toEventuallyNot(beNil())
    }
    
    func testShouldReturnOkBodyWhenCreateATask () {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(201)?
            .withBody(fromJsonFile("addTaskToUserResponse"))
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { result in
            response = result
        }
        
        expect(response).toEventuallyNot(beNil())
        assertTaskContainsExpectedValues((response?.value)!)
    }
    
    func testShouldReturnFailureWhenCreateATask () {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(418)
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { result in
            response = result
        }
        
        expect(response?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 418)))
    }
    
    func testShouldReturnServerErrorWhenCreateATask () {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(500)
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { result in
            response = result
        }
        
        expect(response?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
    }
    
    func testShouldReturnOKStatusWhenCreateATask () {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(201)?
            .withBody(fromJsonFile("addTaskToUserResponse"))
        
        var response: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { result in
            response = result
        }
    
        expect(response).toEventuallyNot(beNil())
    }

    //DELETE
    
    func testShouldReturnOKWhenDeleteATask () {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(200)
        
        var response: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { result in
            response = result
        }
        
        expect(response).toEventuallyNot(beNil())
        expect(response?.error).to(beNil())
    }
    
    func testShouldReturnOKWhenDeleteATaskAndServerReturnASuccess () {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(200)
        
        var response: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { result in
            response = result
        }
        
        expect(response).toEventuallyNot(beNil())
        expect(response?.error).to(beNil())
    }
    
    func testShouldReturnOKWhenTheServerReturnsServerErrorDeletingATask () {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(500)
        
        var response: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { result in
            response = result
        }
        
        expect(response?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
    }
    
    func testShouldReturOKWhenTheServerNotFoundTheTaskToDelete () {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(404)
        
        var response: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { result in
            response = result
        }
        
        expect(response?.error).toEventually(equal(TODOAPIClientError.itemNotFound))
    }
    
    
    fileprivate func assertTaskContainsExpectedValues(_ task: TaskDTO) {
        expect(task.id).to(equal("1"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("delectus aut autem"))
        expect(task.completed).to(beFalse())
    }
    
    fileprivate func assertUpdatedTaskContainsExpectedValues(_ task: TaskDTO) {
        expect(task.id).to(equal("2"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("Finish this kata"))
        expect(task.completed).to(beTrue())
    }
    
    
   
}

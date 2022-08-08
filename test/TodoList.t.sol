// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TodoList.sol";

contract TodoListTest is Test {
    TodoList public todoList;
    string content = "todo1";
    uint256 longPendingPeriod = 1000;
    uint256 shortPendingPeriod = 0;
    uint256 timestamp = 1641070800;

    function setUp() public {
        todoList = new TodoList();
        todoList.addTodoItem(content);
        vm.warp(timestamp);
    }

    function testAddTodoItem() public {
        TodoItem memory todoItem = todoList.getTodoItem(0);
        PendingContext memory pendingContext = todoItem.pendingContext;
        assertEq(todoItem.content, content);
        assertEq(todoItem.isCompleted, false);
        assertEq(pendingContext.isPending, false);
        assertEq(pendingContext.time, 0);
        assertEq(pendingContext.pendingPeriod, 0);
    }

    function testGetNumberOfTodoItems() public {
        assertEq(todoList.getNumberOfTodoItems(), 1);
    }

    function testDeleteTodo() public {
        todoList.deleteTodo(0);
        TodoItem memory todoItem = todoList.getTodoItem(0);
        PendingContext memory pendingContext = todoItem.pendingContext;
        assertEq(todoItem.content, "");
        assertEq(todoItem.isCompleted, false);
        assertEq(pendingContext.isPending, false);
        assertEq(pendingContext.time, 0);
        assertEq(pendingContext.pendingPeriod, 0);
    }

    function testAllTodoItems() public {
        TodoItem[] memory todoItems = todoList.getAllTodoItems();

        for (uint256 index = 0; index < todoItems.length; index++) {
            PendingContext memory pendingContext = todoItems[index].pendingContext;
            assertEq(todoItems[index].content, content);
            assertEq(todoItems[index].isCompleted, false);
            assertEq(pendingContext.isPending, false);
            assertEq(pendingContext.time, 0);
            assertEq(pendingContext.pendingPeriod, 0);
        }
    }

    function testCompleteTodoItem() public {
        todoList.completeTodoItem(0);
        TodoItem memory todoItem = todoList.getTodoItem(0);
        PendingContext memory pendingContext = todoItem.pendingContext;
        assertEq(todoItem.content, content);
        assertEq(todoItem.isCompleted, true);
        assertEq(pendingContext.isPending, false);
        assertEq(pendingContext.time, 0);
        assertEq(pendingContext.pendingPeriod, 0);
    }

    function testClearCompletedTodoItems() public {
        todoList.completeTodoItem(0);
        todoList.clearCompletedTodoItems();
        TodoItem memory todoItem = todoList.getTodoItem(0);
        PendingContext memory pendingContext = todoItem.pendingContext;

        assertEq(todoItem.content, "");
        assertEq(todoItem.isCompleted, false);
        assertEq(pendingContext.isPending, false);
        assertEq(pendingContext.time, 0);
        assertEq(pendingContext.pendingPeriod, 0);
    }

    function testPendTodoItem() public {
        todoList.pendTodoItem(0, longPendingPeriod);
        TodoItem memory todoItem = todoList.getTodoItem(0);
        PendingContext memory pendingContext = todoItem.pendingContext;
        assertEq(pendingContext.isPending, true);
        assertEq(pendingContext.time, timestamp);
        assertEq(pendingContext.pendingPeriod, longPendingPeriod);

        vm.expectRevert("The todo item is pending!");
        todoList.pendTodoItem(0, longPendingPeriod);
    }

    function testRestoreTodoItem() public {
        todoList.pendTodoItem(0, longPendingPeriod);
        todoList.restoreTodoItem(0);
        TodoItem memory todoItem = todoList.getTodoItem(0);
        PendingContext memory pendingContext = todoItem.pendingContext;
        assertEq(pendingContext.isPending, false);
        assertEq(pendingContext.time, 0);
        assertEq(pendingContext.pendingPeriod, 0);

        string memory todo2Content = 'todo2';
        todoList.addTodoItem(todo2Content);
        todoList.pendTodoItem(1, shortPendingPeriod);
        vm.warp(timestamp + 10);
        vm.expectRevert("You exccess pending period!");
        todoList.restoreTodoItem(1);
    }
}

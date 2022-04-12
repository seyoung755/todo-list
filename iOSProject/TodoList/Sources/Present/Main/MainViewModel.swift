//
//  MainViewModel.swift
//  TodoList
//
//  Created by seongha shin on 2022/04/09.
//

import Combine
import Foundation

struct MainViewModelAction {
    let loadColumns = PassthroughSubject<Void, Never>()
}

struct MainViewModelState {
    let loadedColumns = PassthroughSubject<[ColumnViewModelProtocol], Never>()
}

protocol MainViewModelBinding {
    var action: MainViewModelAction { get }
    var state: MainViewModelState { get }
}

typealias MainViewModelProtocol = MainViewModelBinding

class MainViewModel: MainViewModelProtocol {
    
    private var cancellables = Set<AnyCancellable>()
    private let todoRepository: TodoRepository = TodoRepositoryImpl()
    
    let action = MainViewModelAction()
    let state = MainViewModelState()
    
    init() {
        let requestLoadColumns = action.loadColumns
            .map {
                self.todoRepository.loadColumns()}
            .switchToLatest()
            .share()
        
        requestLoadColumns
            .compactMap{ $0.value }
            .map { columns in
                columns.columns.map { column in ColumnViewModel(column: column)}
            }
            .sink(receiveValue: self.state.loadedColumns.send(_:))
            .store(in: &cancellables)
        
        requestLoadColumns
            .compactMap{ $0.error }
            .sink { error in
                print(error)
            }.store(in: &cancellables)
    }
}

//
//  TodoViewController.swift
//  TodoList
//
//  Created by seongha shin on 2022/04/04.
//

import Combine
import UIKit

protocol ColumnViewDelegate {
    func columnView(_ columnView: ColumnViewController, fromCard: Card, toColumn: Card.Column)
}

protocol ColumnViewProperty {
    var controller: ColumnViewController { get }
}

protocol ColumnViewInput {
    func addCard(_ card: Card)
}

class ColumnViewController: UIViewController, ColumnViewProperty {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "해야할 일"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "100"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .gray4
        label.padding = .init(top: 8, left: 9, bottom: 8, right: 9)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 13
        return label
    }()
    
    private let cardTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ColumnViewCell.self, forCellReuseIdentifier: "ColumnViewCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let addButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)

        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_add"), for: .normal)
        return button
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let model: ColumnViewModelBinding & ColumnViewModelProperty
    
    var controller: ColumnViewController {
        self
    }
    
    var delegate: ColumnViewDelegate?
    
    init(model: ColumnViewModelBinding & ColumnViewModelProperty) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.model = ColumnViewModel(columnType: .todo)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        layout()
        
        model.action.loadColumn.send()
    }
    
    private func bind() {
        cardTableView.delegate = self
        cardTableView.dataSource = self
        
        addButton.publisher(for: .touchUpInside)
            .sink(receiveValue: model.action.tappedAddButton.send(_:))
            .store(in: &cancellables)
        
        model.state.showCardPopup
            .sink(receiveValue: self.showCardPopup(_:))
            .store(in: &cancellables)
        
        model.state.loadedColumn
            .sink { count, colunm in
                self.titleLabel.text = colunm.titleName
                self.countLabel.text = String(count)
                self.cardTableView.reloadData()
            }.store(in: &cancellables)
        
        model.state.insertedCard
            .sink {
                self.cardTableView.insertRows(at: [IndexPath(item: $0, section: 0)], with: .none)
                self.countLabel.text = String(self.model.cardCount)
            }.store(in: &cancellables)
        
        model.state.deletedCard
            .sink {
                self.cardTableView.deleteRows(at: [IndexPath(item: $0, section: 0)], with: .none)
                self.countLabel.text = String(self.model.cardCount)
            }.store(in: &cancellables)
        
        model.state.movedCard
            .sink { card, toColumn in
                self.delegate?.columnView(self, fromCard: card, toColumn: toColumn)
                self.countLabel.text = String(self.model.cardCount)
            }.store(in: &cancellables)
        
        model.state.reloadCard
            .sink {
                self.cardTableView.reloadRows(at: [IndexPath(item: $0, section: 0)], with: .none)
            }.store(in: &cancellables)
    }
    
    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(countLabel)
        view.addSubview(addButton)
        view.addSubview(cardTableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            
            countLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countLabel.heightAnchor.constraint(equalToConstant: 26),
            
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            
            cardTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            cardTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cardTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cardTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  -10)

        ])
    }
    
    private func showCardPopup(_ popupData: CardPopupData) {
        let popup = CardPopupViewController(model: CardPopupViewModel(popupData: popupData) )
        popup.modalPresentationStyle = .overCurrentContext
        present(popup, animated: false)
        popup.delegate = self
    }
}

extension ColumnViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.cardCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColumnViewCell") as? ColumnViewCell,
              let card = model[indexPath.item] else {
            return UITableViewCell()
        }
        cell.setCard(card)
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let moveDone = UIAction(title: "완료한 일로 이동") { _ in
                self.model.action.tappedMoveCardButton.send(indexPath.item)
            }
            
            let edit = UIAction(title: "수정하기") { _ in
                self.model.action.tappedEditButton.send(indexPath.item)
            }
            
            let delete = UIAction(title: "삭제하기", attributes: .destructive) { _ in
                self.model.action.tappedDeleteButton.send(indexPath.item)
            }
            return UIMenu(title: "", children: [moveDone, edit, delete])
        }
    }
}

extension ColumnViewController: ColumnViewInput {
    func addCard(_ card: Card) {
        model.action.addCard.send(card)
    }
}

extension ColumnViewController: CardPopupViewDeletegate {
    func cardPopupView(_ cardPopupView: CardPopupViewController, editedCard: Card) {
        model.action.editCard.send(editedCard)
    }
    
    func cardPopupView(_ cardPopupView: CardPopupViewController, addedCard: Card) {
        model.action.addCard.send(addedCard)
    }
}

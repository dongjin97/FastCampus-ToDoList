//
//  ViewController.swift
//  ToDoList
//
//  Created by 원동진 on 2022/04/06.
//
//Start

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    //weak 가 아닌 strong 인 이유 : weak 이면 왼쪽 네비게이션 아이템을 done 으로 바꾸면 edit버튼이 메모리에서 해제되어서 더이상 재사용 불가
    var doneButton : UIBarButtonItem?
    var tasks = [Task](){
        didSet{
            self.saveTasks()
        }
        //할일들이 추가될때마다 saveTasks 를 호출하여 할일들을 저장하고 앱을 재실행했을때 저장된 할일들을 load
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        //#selector(@objc method)-> 동적 호출등에 목적으로 사용 되었는데 swift로 넘어오면서 구조체 형식으로 정의가 되고 해당타입에 값을 생성할수 있게 됨
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks()
        // Do any additional setup after loading the view.
    }
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else {return}
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        //alert
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        //handler : 클로저를 정의 ,alert 버튼을 눌렀을때 파라미터에 정의된 클로저함수가 호출 , 사용자가 alert버튼을 눌렀을때 실행해야하는 행동을 정의
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?[0].text else {return}
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
            //등록 버튼을 눌렀을때 텍스트필드에 입력된 값을 가져올수있다
            //이 텍스트필드라는 프로퍼티는 배열 이다 , 텍스트필드를 alert 에 하나만 추가하였기때문에 [0]
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        //nil :별 다른 행동을 취하지 않기 때문에 nil로 설정
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요."
        })
        self.present(alert, animated: true, completion: nil)
    }
    func saveTasks(){
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done":$0.done
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    func loadTasks(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String:Any]] else {return}
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done)
        }
    }
    
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if self.tasks.isEmpty{
            self.doneButtonTap()
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row] //배열요소 접근
        tasks.remove(at: sourceIndexPath.row)//원래 위치에 있는 할일 삭제
        tasks.insert(task, at: destinationIndexPath.row) //destinationIndexPath.row :이동한 위치
        self.tasks = tasks
    }
}
extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

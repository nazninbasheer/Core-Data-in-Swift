import UIKit
import CoreData

class StudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var students: [Student] = []
    var filteredStudents: [Student] = []
    var isFiltering: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self

        let context = CoreDataManager.shared.context
        students = fetchStudents(context: context)
        tableView.reloadData()
    }

    // MARK: UITableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredStudents.count : students.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        let student = isFiltering ? filteredStudents[indexPath.row] : students[indexPath.row]
        cell.textLabel?.text = student.name ?? "No Name"
        cell.detailTextLabel?.text = "ID: \(student.id)  Age: \(student.age)"

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterStudents(for: searchText)
    }

    func filterStudents(for searchText: String) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Student> = Student.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            filteredStudents = try context.fetch(request)
        } catch {
            print("Failed to fetch filtered students: \(error.localizedDescription)")
            filteredStudents = []
        }
        tableView.reloadData()
    }


    // MARK: IBAction for + button (connected from storyboard)

    @IBAction func addStudentTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Student", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.placeholder = "Student ID (Number)" }
        alert.addTextField { $0.placeholder = "Student Name" }
        alert.addTextField {
            $0.placeholder = "Age (Number)"
            $0.keyboardType = .numberPad
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let idText = alert.textFields?[0].text,
                  let id = Int16(idText),
                  let name = alert.textFields?[1].text,
                  !name.isEmpty,
                  let ageText = alert.textFields?[2].text,
                  let age = Int16(ageText)
            else {
                self.showError(message: "Please enter valid student details")
                return
            }

            self.saveStudent(id: id, name: name, age: age)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: Core Data Helpers

    func fetchStudents(context: NSManagedObjectContext) -> [Student] {
        let request: NSFetchRequest<Student> = Student.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

//        if let filter = nameFilter, !filter.isEmpty {
//                // Filter using case-insensitive contains
//                request.predicate = NSPredicate(format: "name CONTAINS[c] %@", filter)
//            }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch students: \(error.localizedDescription)")
            return []
        }
    }

    func isStudentAlreadyAdded(id: Int16, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<Student> = Student.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Failed to check student existence: \(error.localizedDescription)")
            return false
        }
    }

    func saveStudent(id: Int16, name: String, age: Int16) {
        let context = CoreDataManager.shared.context

        // Avoid duplicates
        if isStudentAlreadyAdded(id: id, context: context) {
            showError(message: "Student with this ID already exists!")
            return
        }

        let student = Student(context: context)
        student.id = id
        student.name = name
        student.age = age

        do {
            try context.save()
            students = fetchStudents(context: context)
            tableView.reloadData()
        } catch {
            showError(message: "Failed to save student: \(error.localizedDescription)")
        }
    }

    // MARK: Error Alert

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

import UIKit
import CoreData

class TeacherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var teachers: [Teacher] = []
    var filteredTeachers: [Teacher] = []
    var isFiltering: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        let context = CoreDataManager.shared.context
        teachers = fetchTeachers(context: context)
        tableView.reloadData()
    }

    // UITableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredTeachers.count : teachers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "teacherCell", for: indexPath)

        let teacher = isFiltering ? filteredTeachers[indexPath.row] : teachers[indexPath.row]
        cell.textLabel?.text = teacher.name ?? "No Name"
        cell.detailTextLabel?.text = "ID: \(teacher.id)  Subject: \(teacher.course ?? "N/A")"

        return cell
    }

    //   UITableView Delegate Methods (Edit/Delete)

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let teacher = isFiltering ? filteredTeachers[indexPath.row] : teachers[indexPath.row]
        showEditAlert(for: teacher)
    }

    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let teacher = isFiltering ? filteredTeachers[indexPath.row] : teachers[indexPath.row]
            deleteTeacher(teacher)
        }
    }

    //  SearchBar Delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTeachers(for: searchText)
    }

    func filterTeachers(for searchText: String) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            filteredTeachers = try context.fetch(request)
        } catch {
            print("Failed to fetch filtered teachers: \(error.localizedDescription)")
            filteredTeachers = []
        }
        tableView.reloadData()
    }

    //  Add Teacher

    @IBAction func addTeacherTapped(_ sender: UIBarButtonItem) {
        showAddAlert()
    }

    private func showAddAlert() {
        let alert = UIAlertController(title: "Add New Teacher", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.placeholder = "Teacher ID (Number)" }
        alert.addTextField { $0.placeholder = "Teacher Name" }
        alert.addTextField { $0.placeholder = "Course" }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let idText = alert.textFields?[0].text,
                  let id = Int16(idText),
                  let name = alert.textFields?[1].text, !name.isEmpty,
                  let course = alert.textFields?[2].text, !course.isEmpty
            else {
                self.showError(message: "Please enter valid teacher details")
                return
            }

            self.saveTeacher(id: id, name: name, course: course)
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    //  Edit Teacher

    private func showEditAlert(for teacher: Teacher) {
        let alert = UIAlertController(title: "Edit Teacher", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.text = "\(teacher.id)" }
        alert.addTextField { $0.text = teacher.name }
        alert.addTextField { $0.text = teacher.course }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let idText = alert.textFields?[0].text,
                  let id = Int16(idText),
                  let name = alert.textFields?[1].text, !name.isEmpty,
                  let course = alert.textFields?[2].text, !course.isEmpty
            else {
                self.showError(message: "Please enter valid teacher details")
                return
            }

            self.updateTeacher(teacher, newId: id, newName: name, newCourse: course)
        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    //   Core Data Helpers

    func fetchTeachers(context: NSManagedObjectContext) -> [Teacher] {
        let request: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch teachers: \(error.localizedDescription)")
            return []
        }
    }

    func isTeacherAlreadyAdded(id: Int16, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            return try context.count(for: request) > 0
        } catch {
            print("Failed to check teacher existence: \(error.localizedDescription)")
            return false
        }
    }

    func saveTeacher(id: Int16, name: String, course: String) {
        let context = CoreDataManager.shared.context

        if isTeacherAlreadyAdded(id: id, context: context) {
            showError(message: "Teacher with this ID already exists!")
            return
        }

        let teacher = Teacher(context: context)
        teacher.id = id
        teacher.name = name
        teacher.course = course

        do {
            try context.save()
            teachers = fetchTeachers(context: context)
            tableView.reloadData()
        } catch {
            showError(message: "Failed to save teacher: \(error.localizedDescription)")
        }
    }

    func updateTeacher(_ teacher: Teacher, newId: Int16, newName: String, newCourse: String) {
        let context = CoreDataManager.shared.context
        teacher.id = newId
        teacher.name = newName
        teacher.course = newCourse

        do {
            try context.save()
            teachers = fetchTeachers(context: context)
            tableView.reloadData()
        } catch {
            showError(message: "Failed to update teacher: \(error.localizedDescription)")
        }
    }

    func deleteTeacher(_ teacher: Teacher) {
        let context = CoreDataManager.shared.context
        context.delete(teacher)

        do {
            try context.save()
            teachers = fetchTeachers(context: context)
            tableView.reloadData()
        } catch {
            showError(message: "Failed to delete teacher: \(error.localizedDescription)")
        }
    }

    //   Error Alert

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//
//  ViewController.swift
//  CoreDataSwift
//
//  Created by DDUKK19 on 22/08/25.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = CoreDataManager.shared.context
    
   //adding data
//        let student = Student(context:context)
//        student.id = 701
//        student.name = "Richard"
//        student.age = 21
//
//
//        let teacher = Teacher(context:context)
//        teacher.name = "Rose"
//        teacher.id = 101
//        teacher.course = "Maths"
//
        do {
                   try context.save()
                   print("Saved successfully")
               } catch {
                   print("Error saving context: \(error.localizedDescription)")
               }
        let students = fetchStudent(context: context)
        let teachers = fetchTeacher(context: context)
       
        //edit student
        
//        if let firstStudent = students.first{
//            editStudent(student: firstStudent, newName: "Naznin Basheer", newAge: 21, context: context)
//        }

        //edit teacher`
//            if let firstTeacher = teachers.first{
//                editTeacher(teacher: firstTeacher, newName: "Rose Mini", newCourse: "Mathematics", context: context)
//            }
//
//        //delete last student
//        if let lastStudent = students.last {
//            deleteStudent(student: lastStudent, context: context)
//        }
//
//       //delete last teacher
//        if let lastTeacher = teachers.last {
//            deleteTeacher(teacher: lastTeacher, context: context)
//        }

        
        // Fetch and print students
               
                print("Students:")
                for student in students {
                    print("Id:\(student.id)  Name: \(student.name ?? "No name"), Age: \(student.age)")
                }
                
                print("Teacher:")
                for teacher in teachers {
                    print("Id:\(teacher.id)  Name: \(teacher.name ?? "No name"), Course: \(teacher.course ?? "No Course")")
                }
               

        
    }
    
     //function to fetch student
    func fetchStudent(context :NSManagedObjectContext) -> [Student] {
        let Request :NSFetchRequest<Student> = Student.fetchRequest()
        Request.sortDescriptors = [NSSortDescriptor(key:"id", ascending: true)]
        do {
                    return try context.fetch(Request)
                } catch {
                    print("Failed to fetch students")
                    return[]
            }
    }
    
    //function to fetch teacher
    func fetchTeacher(context :NSManagedObjectContext) -> [Teacher]{
        let request :NSFetchRequest<Teacher> = Teacher.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending :true)]
        do {
            return try context.fetch(request)
        }catch{
            print("failed to fetch Teacher")
            return[]
        }
    }
    
    //function to edit student
//    func editStudent(student :Student,newName :String,newAge :Int16, context :NSManagedObjectContext)  {
//        student.name = newName
//        student.age = newAge
//        do{
//            try context.save()
//            print("student edit success")
//        }catch{
//            print("student edit failed")
//        }
//    }
//
//    //function to edit teacher
//    func editTeacher(teacher :Teacher, newName :String, newCourse: String, context :NSManagedObjectContext){
//        teacher.name = newName
//        teacher.course = newCourse
//
//        do{
//            try context.save()
//            print("Teacher edit success")
//        }catch{
//            print("failed in editing Teacher data")
//        }
//    }
    
    //function to delete student
//    func deleteStudent(student: Student, context: NSManagedObjectContext) {
//           context.delete(student)
//           do {
//               try context.save()
//               print("Student deleted successfully")
//           } catch {
//               print("Failed to delete student: \(error.localizedDescription)")
//           }
//       }
//
//    //function to delete teacher
//    func deleteTeacher(teacher: Teacher, context: NSManagedObjectContext) {
//           context.delete(teacher)
//           do {
//               try context.save()
//               print("Student deleted successfully")
//           } catch {
//               print("Failed to delete student: \(error.localizedDescription)")
//           }
//       }
    
    
    

}


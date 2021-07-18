//
//  DataManager.swift
//  middle_todo
//
//  Created by suhee❤️ on 2021/07/18.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    private init() {
        // 싱글톤(Singleton) 패턴, 하나의 인스턴스로 공유
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 메모를 DB에서 읽어오기
    // 빈 배열로 초기화
    var memoList = [Memo]()
    
    func fetchMemo() {
        // 읽어오기(fetch)
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        // 내림차순 정렬
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        // 보여주기
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    // 메모를 DB에 추가하기
    func addNewMemo(_ memo: String?) {
        // 비어있는 인스턴스 생성
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = Date()
        
        // memoList.append는 배열 맨 뒤에 저장
        memoList.insert(newMemo, at: 0)
        
        // 컨텍스트 저장
        saveContext()
    }
    
    // 메모를 DB에서 삭제하기
    func deleteMemo(_ memo:Memo?) {
        if let memo = memo {
            mainContext.delete(memo)
            saveContext()
        }
    }
    
    // Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "middle")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

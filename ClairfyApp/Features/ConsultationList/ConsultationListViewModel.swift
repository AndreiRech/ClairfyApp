//
//  ConsultationListViewModel.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftUI

@Observable
class ConsultationListViewModel: ConsultationListViewModelProtocol {
    private let repository: ConsultationListRepositoryProtocol
    
    var consultations: [Consultation] = []
    var selectedConsultation: Consultation?
    var shouldRecordAudio: Bool = false
    var searchText: String = ""
    var filteredConsultations: [Consultation] {
        if searchText.isEmpty {
            return consultations
        } else {
            return consultations.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init(repository: ConsultationListRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchConsultations() {
        do {
            consultations = try repository.fetchConsultations()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteConsultation(by id: UUID) {
        do {
            try repository.deleteConsultation(by: id)
            fetchConsultations()
        } catch {
            print(error.localizedDescription)
        }
    }
}

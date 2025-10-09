//
//  ConsultationListViewModelProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

protocol ConsultationListViewModelProtocol {
    var consultations: [Consultation] { get set }
    var selectedConsultation: Consultation? { get set }
    var shouldRecordAudio: Bool { get set }
    var searchText: String { get set }
    var filteredConsultations: [Consultation] { get }
    
    func fetchConsultations()
    func deleteConsultation(by id: UUID)
}

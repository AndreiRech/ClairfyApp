//
//  AnalysisViewModelProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

protocol AnalysisViewModelProtocol {
    var consultation: Consultation { get }
    var isLoading: Bool { get set }
    var selectedSegment: Int { get set }
    var errorMessage: String? { get set }
    
    func generateAnalysis() async
}

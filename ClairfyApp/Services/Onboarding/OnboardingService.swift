//
//  OnboardingService.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

class OnboardingService: OnboardingServiceProtocol {
    func getOnboardingData() -> [OnboardingPage] {
        return [
            OnboardingPage(imageName: "DoctorOnboarding", title: "Grave e acompanhe cada detalhe da sua consulta", highlight: "Grave", description: "Deixe as anotações por nossa conta e converse com o seu paciente sem distrações."),
            
            OnboardingPage(imageName: "PreviewOnboarding", title: "Receba um resumo prático e os próximos passos", highlight: "resumo prático", description: "Transformamos a conversa em pontos de ação para você enviar para seu paciente após a consulta."),
            
            OnboardingPage(imageName: "DataOnboarding", title: "Seus dados, sua segurança, sua privacidade", highlight: "sua segurança", description: "Todo o processamento é criptografado; só você decide quem acessa suas informações.")
        ]
    }
    
    func getTermsAndConditions() -> String {
        """
        Ao continuar, você concorda com os seguintes pontos:

        1. Consentimento do Paciente: É sua total e exclusiva responsabilidade obter a permissão explícita do paciente ANTES de iniciar qualquer gravação.

        2. Ferramenta de Apoio, Não Diagnóstico: O Clairfy é uma ferramenta de suporte. Os resumos da IA NÃO são um diagnóstico médico e não substituem o julgamento clínico. As decisões de tratamento são de responsabilidade exclusiva do profissional.

        3. Dever de Revisão Crítica: A IA pode cometer erros ou omissões. É seu dever OBRIGATÓRIO revisar e validar a precisão de todos os resumos antes de qualquer uso.

        4. Isenção de Responsabilidade: Você assume total responsabilidade legal e ética pelo uso do aplicativo. Os desenvolvedores do Clairfy não se responsabilizam por quaisquer danos, erros clínicos ou violações legais decorrentes do uso da ferramenta.
        """
    }
}

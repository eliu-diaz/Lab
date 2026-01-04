//
//  PomoDuoSession+Container.swift
//  PomoDuoSession
//
//  Created by Eliu Diaz on 27/12/25.
//

import Foundation
import FactoryKit

extension Container {
    public var sessionManager: Factory<PomoDuoSessionManager> {
        Factory(self) { _PomoDuoSessionManager() }
    }
}

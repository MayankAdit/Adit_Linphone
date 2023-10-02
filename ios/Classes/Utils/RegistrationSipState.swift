//
//  RegistrationSipState.swift
//  adit_lin_plugin
//
//  Created by Adit Mac1 on 02/10/23.
//

import Foundation

enum RegisterSipState : String, CaseIterable {
    /// Initial state for registrations.
    case None = "None"
    /// Registration is in progress.
    case Progress = "Progress"
    /// Registration is successful.
    case Ok = "Ok"
    /// Unregistration succeeded.
    case Cleared = "Cleared"
    /// Registration failed.
    case Failed = "Failed"
}

//
//  SmsConfirmationSmsConfirmationRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol SmsConfirmationRouterProtocol: SignUpSuccessRouterProtocol {}

///
final class SmsConfirmationRouter: BaseRouter, SmsConfirmationRouterProtocol {}

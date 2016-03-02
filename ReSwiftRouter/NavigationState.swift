//
//  NavigationState.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

public protocol RouteElementIdentifier {}
extension String: RouteElementIdentifier {}
public typealias Route = [RouteElementIdentifier]

public struct NavigationState {
    public init() {}

    public var route: Route = []
    public var subRouteState: [StateType] = []
}

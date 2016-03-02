//
//  SwiftFlowRouterUnitTests.swift
//  Meet
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble

import ReSwift
@testable import ReSwiftRouter

class ReSwiftRouterUnitTests: QuickSpec {

    // Used as test app state
    struct AppState: StateType {}

    override func spec() {
        describe("routing calls") {

            let tabBarViewControllerIdentifier = "TabBarViewController"
            let counterViewControllerIdentifier = "CounterViewController"
            let statsViewControllerIdentifier = "StatsViewController"
            let infoViewControllerIdentifier = "InfoViewController"

            var router: Router<FakeAppState>!

            beforeEach {
                let store = Store(reducer: CombinedReducer([AppReducer()]), state: FakeAppState())
                let routable = FakeRoutable()
                router = Router(store: store, rootRoutable: routable) { state in
                    state.navigationState
                }
            }

            it("calculates transitions from an empty route to a multi segment route") {
                let oldRoute: Route = []
                let newRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.Push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 0
                            && segmentToBePushed as? String == tabBarViewControllerIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.Push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed as? String == statsViewControllerIdentifier {
                            action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on the last common subroute") {
                let oldRoute: Route = [tabBarViewControllerIdentifier, counterViewControllerIdentifier]
                let newRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElementIdentifier?
                var new: RouteElementIdentifier?

                if case let RoutingActions.Change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(1))
                expect(toBeReplaced as? String).to(equal(counterViewControllerIdentifier))
                expect(new as? String).to(equal(statsViewControllerIdentifier))
            }

            it("generates a Change action on the last common subroute, also for routes of different length") {
                let oldRoute: Route = [tabBarViewControllerIdentifier, counterViewControllerIdentifier]
                let newRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier,
                    infoViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.Change(responsibleRoutableIndex, segmentToBeReplaced,
                    newSegment)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBeReplaced as? String == counterViewControllerIdentifier
                            && newSegment as? String == statsViewControllerIdentifier{
                                action1Correct = true
                        }
                }

                if case let RoutingActions.Push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed as? String == infoViewControllerIdentifier {

                                action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on root when root element changes") {
                let oldRoute: Route = [tabBarViewControllerIdentifier]
                let newRoute: Route = [statsViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElementIdentifier?
                var new: RouteElementIdentifier?

                if case let RoutingActions.Change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(0))
                expect(toBeReplaced as? String).to(equal(tabBarViewControllerIdentifier))
                expect(new as? String).to(equal(statsViewControllerIdentifier))
            }

            it("calculates no actions for transition from empty route to empty route") {
                let oldRoute: Route = []
                let newRoute: Route = []

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates no actions for transitions between identical, non-empty routes") {
                let oldRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]
                let newRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates transitions with multiple pops") {
                let oldRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier,
                    counterViewControllerIdentifier]
                let newRoute: Route = [tabBarViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.Pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePopped as? String == counterViewControllerIdentifier {
                                action1Correct = true
                            }
                }

                if case let RoutingActions.Pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePopped as? String == statsViewControllerIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

            it("calculates transitions with multiple pushes") {
                let oldRoute: Route = [tabBarViewControllerIdentifier]
                let newRoute: Route = [tabBarViewControllerIdentifier, statsViewControllerIdentifier,
                    counterViewControllerIdentifier]

                let routingActions = router.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.Push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed as? String == statsViewControllerIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.Push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed as? String == counterViewControllerIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

        }
    }

}
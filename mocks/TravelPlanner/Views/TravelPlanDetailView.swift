import SwiftUI
import MapKit

/// Main detail view for a travel plan, combining the map and route details.
struct TravelPlanDetailView: View {
    let plan: TravelPlan
    @State private var viewModel = TravelPlanViewModel()
    @State private var showAllDays = false
    @State private var showRouteDetail = true

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map layer
            TravelMapView(
                viewModel: viewModel,
                dayPlans: showAllDays ? plan.dayPlans : (viewModel.selectedDayPlan.map { [$0] } ?? [])
            )
            .ignoresSafeArea(edges: .top)

            // Bottom overlay
            VStack(spacing: 0) {
                // Day selector
                DaySelectorView(
                    dayPlans: plan.dayPlans,
                    selectedDay: Binding(
                        get: { viewModel.selectedDayPlan },
                        set: { day in
                            if let day {
                                showAllDays = false
                                viewModel.selectDay(day)
                            }
                        }
                    ),
                    showAllDays: showAllDays,
                    onShowAllDays: {
                        showAllDays = true
                        viewModel.selectedDestination = nil
                        viewModel.focusCameraOnAllDays()
                    }
                )
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)

                // Route detail panel (collapsible)
                if showRouteDetail, let selectedDay = viewModel.selectedDayPlan, !showAllDays {
                    ScrollView {
                        RouteDetailView(viewModel: viewModel, dayPlan: selectedDay)
                    }
                    .frame(maxHeight: 320)
                    .background(.regularMaterial)
                    .transition(.move(edge: .bottom))
                }

                // All-days summary
                if showAllDays {
                    AllDaysSummaryView(viewModel: viewModel, plan: plan)
                        .frame(maxHeight: 280)
                        .background(.regularMaterial)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showRouteDetail.toggle()
                    }
                } label: {
                    Image(systemName: showRouteDetail ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                }
            }
        }
        .overlay {
            if viewModel.isCalculatingRoutes {
                VStack {
                    ProgressView("ルートを計算中...")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                .padding(.top, 80)
            }
        }
        .sheet(isPresented: $viewModel.showLookAround) {
            if let destination = viewModel.selectedDestination,
               let scene = viewModel.lookAroundScene {
                LookAroundPreviewSheet(destination: destination, scene: scene)
                    .presentationDetents([.medium, .large])
            }
        }
        .alert("Look Around", isPresented: Binding(
            get: { viewModel.lookAroundError != nil },
            set: { if !$0 { viewModel.lookAroundError = nil } }
        )) {
            Button("OK") { viewModel.lookAroundError = nil }
        } message: {
            Text(viewModel.lookAroundError ?? "")
        }
        .onAppear {
            viewModel.loadPlan(plan)
        }
    }
}

/// Summary view showing all days at a glance.
struct AllDaysSummaryView: View {
    let viewModel: TravelPlanViewModel
    let plan: TravelPlan

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("旅行概要")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 8)

                Text(plan.dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ForEach(plan.dayPlans) { day in
                    DaySummaryRow(day: day, routes: viewModel.routeInfos[day.id] ?? [])
                }
            }
            .padding(.bottom)
        }
    }
}

/// A row summarizing a single day's plan.
struct DaySummaryRow: View {
    let day: DayPlan
    let routes: [RouteInfo]

    private var totalDistance: String {
        let total = routes.reduce(0.0) { $0 + $1.distance }
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(fromDistance: total)
    }

    private var totalTime: String {
        let total = routes.reduce(0.0) { $0 + $1.expectedTravelTime }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(day.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(day.dayNumber): \(day.title)")
                    .font(.subheadline.bold())
                Text("\(day.destinations.count)箇所")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !routes.isEmpty {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(totalDistance)
                        .font(.caption.bold())
                    Text(totalTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

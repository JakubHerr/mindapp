//
//  TrendsView.swift
//  MindApp
//
//  Created by Michael Slavev on 16.04.2024.
//

import SwiftUI

struct TrendsView: View {
    @StateObject private var weekViewModel = WeekPickerViewModel()
    @StateObject private var monthViewModel = MonthPickerViewModel()
    
    @EnvironmentObject private var healthkitViewModel: HealthkitViewModel

    @State private var displayMode: DisplayMode = .weekly
    
    @State private var showAIHealthSummary: Bool = false
    @State private var showAIHealthMotivator: Bool = false
    @State private var showAIHealthSupporter: Bool = false

    @State private var img: UIImage?
    @State private var contentHeight: CGFloat = .zero
    @State private var isTakingScreenshot: Bool = false
    
    @Injected var aiDbManager: AIAppDBManager
    @Injected var coreDataDBManager: CoreDataDBManager
    
    @State private var aiApps: [AIApp] = []
    
    // MARK: View building

    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            ScrollView {
                getView()

                if shouldShowShareButton {
                    Button(action: {
                        Task {
                            await self.screenshot()
                        }
                    }) {
                        Text("trends_share_button")

                        Spacer()

                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.appButtonMain)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding([.horizontal])
                    .padding(.bottom, 15)
                }
            }
            .navigationTitle("trends_header")
            .toolbar {}
            .refreshable {
                try? await Task.sleep(nanoseconds: 750_000_000)

                switch self.displayMode {
                case .weekly:
                    Task {
                        await self.weekViewModel.fetchData()
                    }

                case .monthly:
                    Task {
                        await self.monthViewModel.fetchData()
                    }
                }
            }
            .onAppear {
                Task {
                    await self.weekViewModel.fetchData()
                    await self.monthViewModel.fetchData()
                    do {
//                        self.aiApps = try await self.aiDbManager.fetchAIApps()
                        self.aiApps = try await self.aiDbManager.fetchOwnAIApps()
//                        print("AI apps fetched: \(self.aiApps.count)")
//                        self.coreDataDBManager.saveAIApps(apps: self.aiApps)
                    }
                    catch {
//                        print("Error fetching AI apps: \(error)")
//                        self.aiApps = self.coreDataDBManager.fetchAIApps()
                    }
                }
            }

            if isTakingScreenshot {
                BackgroundBlurGradientView()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: isTakingScreenshot)

                ProgressView()
                    .controlSize(.large)
                    .tint(Color.white)
                    .transition(.scale)
                    .animation(.easeInOut(duration: 0.3), value: isTakingScreenshot)
            }
        }
    }

    // MARK: - functions

    // Main View
    private func getView() -> some View {
        ZStack {
            BackgroundLightGradientView()

            VStack {
                // Select weekly/monthly
                TrendsToggleButtonView(displayMode: self.$displayMode)
                
                // Select trends type view
                switch self.displayMode {
                case .weekly:
                    TrendsWeeklyView()
                        .environmentObject(self.weekViewModel)

                case .monthly:
                    TrendsMonthlyView()
                        .environmentObject(self.monthViewModel)
                }
                
                Section(header:
                    Text("ai_insights")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.appSenBody)
                        .foregroundColor(.appTextDark)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

                ) {
                    VStack {
                        Button(action: {
                            showAIHealthSummary.toggle()
                        }) {
                            Text("get_ai_health_summary")
                                .font(.appSenBody)
                            
                            Spacer()
                            
                            Image(systemName: "brain.head.profile")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.appButtonMain)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])
                        .padding(.bottom, 15)
                        .sheet(isPresented: $showAIHealthSummary) {
                            AISummarySheet(isPresented: $showAIHealthSummary)
                                .environmentObject(AISummaryViewModel(summaryType: DifyAppType.healthSummary))
                                .environmentObject(healthkitViewModel)
                        }
                        
                        Button(action: {
                            showAIHealthMotivator.toggle()
                        }) {
                            Text("get_ai_health_motivation")
                                .font(.appSenBody)
                            
                            Spacer()
                            
                            Image(systemName: "figure.strengthtraining.traditional")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.appButtonMain)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])
                        .padding(.bottom, 15)
                        .sheet(isPresented: $showAIHealthMotivator) {
                            AISummarySheet(isPresented: $showAIHealthMotivator)
                                .environmentObject(AISummaryViewModel(summaryType: DifyAppType.healthMotivator))
                                .environmentObject(healthkitViewModel)
                        }
                        
                        Button(action: {
                            showAIHealthSupporter.toggle()
                        }) {
                            Text("get_ai_health_support")
                                .font(.appSenBody)
                            
                            Spacer()
                            
                            Image(systemName: "hands.and.sparkles")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.appButtonMain)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal])
                        .padding(.bottom, 15)
                        .sheet(isPresented: $showAIHealthSupporter) {
                            AISummarySheet(isPresented: $showAIHealthSupporter)
                                .environmentObject(AISummaryViewModel(summaryType: DifyAppType.healthSupporter))
                                .environmentObject(healthkitViewModel)
                        }
                    }
                    
                }
                if !aiApps.isEmpty {
                    Section(header:
                                Text("dynamic_ai_apps")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.appSenBody)
                        .foregroundColor(.appTextDark)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))
                            
                    ) {
                        ForEach(aiApps.indices, id: \.self) { index in
                            let vm = DynamicAIAppViewModel(app: aiApps[index])
                            NavigationLink(destination: DynamicAIAppView().environmentObject(vm)) {
                                HStack {
                                    Text(aiApps[index].localizations.first?.title ?? "No title")
                                        .font(.appSenBody)
                                        .foregroundStyle(Color.appTextBody)
                                    
                                    Spacer()
                                    
                                    Image(systemName: aiApps[index].iconName)
                                        .imageScale(.large)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.appButtonMain)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
            }
            .padding(.bottom, 10)
            .background(GeometryReader { geometry in
                DispatchQueue.main.async {
                    self.contentHeight = geometry.size.height
                }
                return Color.clear
            })
        }
    }

    private func screenshot() async {
        withAnimation {
            isTakingScreenshot = true
        }

        try? await Task.sleep(nanoseconds: 750_000_000)

        let size = CGSize(width: UIScreen.main.bounds.width, height: contentHeight + 20)
        let rootView = getView().frame(width: UIScreen.main.bounds.width, height: contentHeight + 20)
        img = rootView.snapshot(size: size)

        shareImage()

        withAnimation {
            isTakingScreenshot = false
        }
    }

    private func shareImage() {
        guard let screenshotImage = img else { return }
        let activityController = UIActivityViewController(activityItems: [screenshotImage], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        {
            keyWindow.rootViewController?.present(activityController, animated: true)
        }
    }

    private var shouldShowShareButton: Bool {
        switch displayMode {
        case .weekly:
            return !weekViewModel.hrvDataPoints.isEmpty
        case .monthly:
            return !monthViewModel.hrvDataPoints.isEmpty
        }
    }
}

// MARK: - View extension

extension TrendsView {
    enum DisplayMode {
        case weekly
        case monthly

        mutating func toggle() {
            self = self == .weekly ? .monthly : .weekly
        }
    }
}

extension View {
    func snapshot(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        let view = controller.view!
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    TrendsView()
}

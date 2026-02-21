import SwiftUI
import MapKit

/// スポットの詳細画面 - Look Around表示とチェックイン機能を含む
struct SpotDetailView: View {
    @Environment(PilgrimageSpotStore.self) private var store
    let spot: PilgrimageSpot

    @State private var showCheckInSheet = false
    @State private var checkInNote = ""
    @State private var showCheckInSuccess = false
    @State private var showLookAroundFullScreen = false
    @State private var lookAroundScene: MKLookAroundScene?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダー情報
                headerSection

                // Look Around セクション
                lookAroundSection

                // シーン情報
                sceneInfoSection

                // マップ
                mapSection

                // チェックインセクション
                checkInSection

                // チェックイン履歴
                checkInHistorySection
            }
            .padding()
        }
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCheckInSheet) {
            checkInSheet
        }
        .overlay {
            if showCheckInSuccess {
                checkInSuccessOverlay
            }
        }
        .fullScreenCover(isPresented: $showLookAroundFullScreen) {
            if let scene = lookAroundScene {
                NavigationStack {
                    LookAroundPreview(initialScene: scene)
                        .navigationTitle("Look Around - \(spot.name)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("閉じる") {
                                    showLookAroundFullScreen = false
                                }
                            }
                        }
                }
            }
        }
        .task {
            await fetchLookAroundScene()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Label(spot.category.rawValue, systemImage: spot.category.icon)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(categoryColor.opacity(0.15))
                    .foregroundStyle(categoryColor)
                    .clipShape(Capsule())

                if store.hasCheckedIn(spot: spot) {
                    Label("訪問済み", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }

            Text(spot.workTitle)
                .font(.title2.weight(.bold))

            Text(spot.sceneName)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Look Around

    private var lookAroundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Look Around", systemImage: "binoculars.fill")
                    .font(.headline)

                Spacer()

                if lookAroundScene != nil {
                    Button {
                        showLookAroundFullScreen = true
                    } label: {
                        Label("全画面", systemImage: "arrow.up.left.and.arrow.down.right")
                            .font(.caption)
                    }
                }
            }

            Text("実際の場所を360度見渡して、作品のシーンと比較してみましょう")
                .font(.caption)
                .foregroundStyle(.secondary)

            LookAroundPreviewContainer(coordinate: spot.coordinate)
        }
    }

    // MARK: - Scene Info

    private var sceneInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("シーン情報", systemImage: "film")
                .font(.headline)

            Text(spot.sceneDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Map

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("場所", systemImage: "map")
                .font(.headline)

            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: spot.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )) {
                Marker(spot.name, systemImage: spot.category.icon, coordinate: spot.coordinate)
                    .tint(categoryColor)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )

            Button {
                openInMaps()
            } label: {
                Label("マップAppで開く", systemImage: "arrow.up.right.square")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Check-In

    private var checkInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("チェックイン", systemImage: "mappin.and.ellipse")
                .font(.headline)

            let count = store.checkInCount(for: spot)

            if count > 0 {
                HStack(spacing: 12) {
                    VStack {
                        Text("\(count)")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.tint)
                        Text("回訪問")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        showCheckInSheet = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("再チェックイン")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.bordered)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Button {
                    showCheckInSheet = true
                } label: {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("この場所にチェックインする")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Check-In History

    private var checkInHistorySection: some View {
        let spotCheckIns = store.checkIns.filter { $0.spotID == spot.id }

        return Group {
            if !spotCheckIns.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("訪問履歴", systemImage: "clock")
                        .font(.headline)

                    ForEach(spotCheckIns) { checkIn in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(checkIn.date, style: .date)
                                    .font(.subheadline)
                                if !checkIn.note.isEmpty {
                                    Text(checkIn.note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(checkIn.date, style: .time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)

                        if checkIn.id != spotCheckIns.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Check-In Sheet

    private var checkInSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.tint)

                    Text(spot.name)
                        .font(.title3.weight(.bold))

                    Text(spot.workTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("メモ（任意）")
                        .font(.subheadline.weight(.medium))

                    TextField("感想やメモを入力...", text: $checkInNote, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    performCheckIn()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("チェックイン")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("チェックイン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        showCheckInSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Success Overlay

    private var checkInSuccessOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("チェックイン完了！")
                .font(.title2.weight(.bold))

            Text("\(spot.name)に訪問しました")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Actions

    private func performCheckIn() {
        store.checkIn(spot: spot, note: checkInNote)
        showCheckInSheet = false
        checkInNote = ""

        withAnimation(.spring(duration: 0.5)) {
            showCheckInSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCheckInSuccess = false
            }
        }
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: spot.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = spot.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    private func fetchLookAroundScene() async {
        let request = MKLookAroundSceneRequest(coordinate: spot.coordinate)
        lookAroundScene = try? await request.scene
    }

    private var categoryColor: Color {
        switch spot.category {
        case .anime: return .purple
        case .movie: return .red
        case .drama: return .blue
        case .game: return .green
        }
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: PilgrimageSpot(
            name: "須賀神社",
            workTitle: "君の名は。",
            sceneName: "ラストシーンの階段",
            sceneDescription: "瀧と三葉が再会する感動的なラストシーンの舞台となった階段。",
            latitude: 35.6873,
            longitude: 139.7194,
            category: .anime
        ))
    }
    .environment(PilgrimageSpotStore())
}

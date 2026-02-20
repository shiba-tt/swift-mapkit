import SwiftUI
import CoreLocation

/// 避難所一覧ビュー
struct ShelterListView: View {
    @ObservedObject var viewModel: EvacuationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // 検索・フィルタセクション
                Section {
                    // 種別フィルタ
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "すべて",
                                isSelected: viewModel.selectedShelterType == nil
                            ) {
                                viewModel.selectedShelterType = nil
                            }
                            ForEach(ShelterType.allCases) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    icon: type.iconName,
                                    isSelected: viewModel.selectedShelterType == type
                                ) {
                                    viewModel.selectedShelterType = type
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Toggle("開設中のみ表示", isOn: $viewModel.showOpenOnly)
                        .font(.subheadline)
                }

                // 避難所リスト
                Section {
                    ForEach(viewModel.filteredShelters) { shelter in
                        ShelterRowView(
                            shelter: shelter,
                            location: viewModel.locationManager.effectiveLocation
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectShelter(shelter)
                            dismiss()
                        }
                    }
                } header: {
                    Text("\(viewModel.filteredShelters.count)件の避難所")
                }
            }
            .navigationTitle("避難所一覧")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "避難所名・住所で検索")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

/// 避難所行コンポーネント
struct ShelterRowView: View {
    let shelter: EvacuationShelter
    let location: CLLocation

    var body: some View {
        HStack(spacing: 12) {
            // ステータスアイコン
            ZStack {
                Circle()
                    .fill(shelter.isOpen ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: shelter.shelterTypes.first?.iconName ?? "building.2.fill")
                    .font(.title3)
                    .foregroundStyle(shelter.isOpen ? .green : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(shelter.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    if !shelter.isOpen {
                        Text("閉鎖中")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(.red)
                            .clipShape(Capsule())
                    }
                }

                Text(shelter.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    ForEach(shelter.shelterTypes) { type in
                        Text(type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text("収容: \(shelter.capacity)人")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 距離
            VStack(alignment: .trailing) {
                Text(shelter.formattedDistance(from: location))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// フィルタチップ
struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

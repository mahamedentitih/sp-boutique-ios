import SwiftUI

struct PerfumesView: View {
    @EnvironmentObject var database: DatabaseService
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(database.perfumes) { perfume in
                    NavigationLink(destination: EditPerfumeView(perfume: perfume)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(perfume.name)
                                    .font(.headline)
                                Spacer()
                                Text("$\(Int(perfume.sellPrice))")
                                    .font(.body.bold())
                                    .foregroundColor(.green)
                            }
                            Text(perfume.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack(spacing: 16) {
                                Text("\(perfume.mlSize) ml")
                                Text("Qty: \(perfume.quantity)")
                                Text("Cost: $\(Int(perfume.costPrice))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            database.deletePerfume(id: perfume.id)
                        }
                    }
                }
            }
            .navigationTitle("Perfumes (\(database.perfumes.count))")
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AddPerfumeView()
                }
            }
            .onAppear {
                database.loadPerfumes()
            }
        }
    }
}

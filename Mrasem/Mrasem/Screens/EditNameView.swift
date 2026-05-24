import SwiftUI

struct EditNameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var name: String = AuthenticationManager.shared.userName ?? ""

    private var isArabic: Bool { languageManager.current == .arabic }
    private let brandBrown = Color(red: 0x31/255, green: 0x23/255, blue: 0x1B/255)
    private let fieldBorder = Color(red: 0xF1/255, green: 0xEC/255, blue: 0xEC/255)
    private let textDark = Color(red: 0x26/255, green: 0x24/255, blue: 0x22/255)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 0) {
                VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {
                    Text(isArabic ? "تغيير الاسم" : "Change Name")
                        .font(.custom("ExpoArabic-Medium", size: 14))
                        .foregroundColor(textDark)
                        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)

                    TextField(
                        isArabic ? "أدخل اسمك" : "Enter your name",
                        text: $name
                    )
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .foregroundColor(textDark)
                    .padding(.horizontal, 15)
                    .frame(height: 54)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(fieldBorder, lineWidth: 1))
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)

                Button(action: { save() }) {
                    Text(isArabic ? "حفظ" : "Save")
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(width: 287, height: 56)
                        .background(brandBrown)
                        .cornerRadius(13)
                }
                .padding(.top, 30)

                Spacer()
                }
            }
            .navigationTitle(isArabic ? "تعديل الملف" : "Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isArabic ? "إلغاء" : "Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        AuthenticationManager.shared.saveName(trimmed.isEmpty ? nil : trimmed)
        dismiss()
    }
}

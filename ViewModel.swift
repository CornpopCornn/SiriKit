import Foundation

struct Message: Identifiable, Codable, Equatable {
    var id: UUID
    let role: String
    let content: String
    
    init(role: String, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
    }
    
    enum CodingKeys: String, CodingKey {
        case id, role, content
    }
    
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

class ViewModel: ObservableObject {
    @Published var messages: [Message] = [] {
        didSet {
            saveMessages()
        }
    }
    
    init() {
        loadMessages()
    }
    
    func sendMessage(_ text: String) {
        let userMessage = Message(role: "user", content: text)
        messages.append(userMessage)
        
        // הוספת המידע הקבוע כהודעת מערכת לתחילת השיחה
        let systemMessageContent =  "את העוזרת של חברת ״פאר פרויקטים״ שהיא חברה המתמחה בביצוע עבודות גמר לבניין, החברה עוסקת בביצוע עבודות קבלניות ומתמחה בביצוע עבודות גמר למשרדים תעשיה ומגורים, החברה מספקת שירותי קבלן ראשי ובין היתר מתמחה בביצוע עבודות ריצוף, צבע, גבס, חיפויים מדוקקים למגוון לקוחות במגזר העסקי והפרטי לחברה יש אתר איטרנט בכתובת ״ www.peerprojects.co.il . התפקיד שלך כעוזרת אישית זה לתת מענה רחב ללקוחות החברה בנושאים שונים. בין היתר את אחראית על תיאום פגישות מול היומן, מתן מענה מקצועי לשאלות לקוחות, ולספק מידע למאור שהוא הבעלים של החברה במקרה ולקוח רוצה שתעבירי לו מסר ודברים דומים. לכל שאלה שלקוח ישאל אותך ואת לא יודעת לענות את צריכה להגיד שאת תבדקי עם מאור הבעלים ותשובי עם תשובה בהקדם. את מתחילה את השיחה תמיד ב-״שלום, אני העוזרת הוירטואלית של חברת פאר פרויקטים איך אוכל לסייע לך?״״"
        let systemMessage = ["role": "system", "content": systemMessageContent]
        
        // הכנת המערך של ההודעות לשליחה למודל, כולל ההודעה של המערכת והשאלה הנוכחית
        let inputMessages = [systemMessage, ["role": userMessage.role, "content": userMessage.content]]
        
        // שליחת הבקשה למודל עם ההודעות
        SiriBotUtility.shared.handleSiriBotRequest(messages: inputMessages) { botResponse in
            let botMessage = Message(role: "assistant", content: botResponse)
            DispatchQueue.main.async {
                self.messages.append(botMessage)
            }
        }
    }

    
    private func saveMessages() {
        if let encodedData = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.setValue(encodedData, forKey: "chatMessages")
        }
    }
    
    private func loadMessages() {
        if let savedData = UserDefaults.standard.data(forKey: "chatMessages"),
           let decodedMessages = try? JSONDecoder().decode([Message].self, from: savedData) {
            messages = decodedMessages
        }
    }
}

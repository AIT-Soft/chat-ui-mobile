# CODEMAP – chat-ui-mobile (Flutter, Android)

## Cấu trúc thư mục
- `lib/main.dart` – điểm vào, `ChatApp` (Material 3 sáng/tối), nạp JSON rồi hiện `ChatScreen`.
- `lib/ui/` – màn hình và widget (`chat_screen.dart`, `message_bubble.dart`); `ui/cards/` – thẻ tệp/ảnh/liên kết.
- `lib/theme/` – token màu sáng/tối (`chat_colors.dart`, kèm `contrastRatio`).
- `lib/models/` – mô hình dữ liệu thuần Dart (Participant, Message, FileInfo/ImageInfo/LinkInfo, ChatData).
- `lib/logic/` – hàm thuần: gom nhóm (`message_grouping.dart`), nhãn ngày (`day_label.dart`).
- `lib/data/` – nạp và phân tích JSON (`chat_loader.dart`).
- Gốc repo: `LICENSE` (MIT, Dương Tấn Thành), `README.md`, `.gitignore` (Flutter + khóa/APK).
- `assets/chat-sample.json` – dữ liệu mẫu lược đồ 1.0 (bản sao từ documents/research; hư cấu).
- `test/` – test đơn vị/widget.
- `android/` – dự án Android do `flutter create` sinh; INTERNET chỉ có ở manifest debug/profile (mặc định Flutter), manifest main không có. `android/app/build.gradle.kts`: release chỉ đóng gói arm64-v8a (packaging.jniLibs.excludes; NFR-06, APK app-release.apk 16.801.041 byte, SHA-256 582A5A7BB942345EAB4FBE4696D86AF660EF9AB88A6CD05436B6417B3ACAD0FB, đo bằng flutter build apk --release (khóa debug); số byte/SHA phụ thuộc khóa ký nên khác giữa các máy) và ký bằng `android/key.properties` (keyAlias, keyPassword, storeFile, storePassword; gitignore, không commit); thiếu tệp thì rơi về khóa debug kèm cảnh báo, chỉ để build cục bộ.

## Bảng tính năng
ID | tính năng | tệp:hàm/lớp chính | route/lệnh | test | ghi chú
---|---|---|---|---|---
FR-12 | Nạp JSON 1.0, kiểm schemaVersion | lib/data/chat_loader.dart:loadChatSample, parseChatData | asset `assets/chat-sample.json` | test/chat_loader_test.dart | AC-12.1 (32 tin, 13/11/8)
AC-12.2 | Lỗi có kiểm soát | chat_loader.dart:ChatDataException, chatLoadErrorMessage | – | chat_loader_test.dart "lỗi có kiểm soát" | UI hiện chatLoadErrorMessage (làm ở task UI)
FR-03 | Gom nhóm tin (cùng người/ngày, <5 phút) | lib/logic/message_grouping.dart:groupMessages, inSameGroup | – | test/logic/logic_test.dart | AC-03.1/03.2
FR-04 | Nhãn ngày, đồng hồ tiêm vào | lib/logic/day_label.dart:dayLabel(dayOffset, now) | – | test/logic/logic_test.dart | AC-04.2; thêm /yyyy khi khác năm
FR-01 | Thanh tiêu đề (avatar 40dp initials+avatarColor, tên, trạng thái) | lib/ui/chat_screen.dart:ChatScreen (key appbar-avatar) | – | test/chat_screen_test.dart | peer.name/status/initials/avatarColor; nhãn ngày _DayPill có Semantics header (AC-04.3)
FR-02 | Danh sách tin, bong bóng ≤75%, cuộn sẵn cuối | chat_screen.dart (ListView reverse), message_bubble.dart:MessageBubble | – | chat_screen_test.dart | tin file/ảnh/link dùng thẻ (FR-07)
FR-11 | Dải chú thích mẫu cố định dưới tiêu đề (nguyên văn disclaimer, Semantics) | lib/ui/disclaimer_banner.dart:DisclaimerBanner, tích hợp chat_screen.dart (Column ngoài ListView) | – | test/disclaimer_banner_test.dart | không cuộn theo danh sách; tự xuống dòng ở chữ 200%
FR-07 | Thẻ tệp (id 5,10,30), ảnh (16, aspect 1,5), liên kết (22); không bấm được | lib/ui/cards/{file,image,link}_card.dart, message_card.dart:buildMessageCard, card_style.dart; gọi từ message_bubble.dart | – | test/cards_test.dart | key card-<id>, image-aspect; màu thẻ đến/đi sáng/tối
FR-04/05 | Phân cách ngày; giờ ở tin cuối nhóm | chat_screen.dart:_DayPill, message_bubble.dart | – | chat_screen_test.dart | `now` tiêm vào ChatScreen
AC-12.3 | Không gọi mạng | toàn bộ lib/ | – | – | không import http/dart:io trong lib/

## Điểm mở rộng
- Thêm loại thẻ mới: thêm widget trong lib/ui/cards/ và nhánh trong buildMessageCard.
- Thêm loại tin mới: thêm giá trị vào `MessageType` (lib/models/message.dart) và nhánh trong `_parseMessage` (chat_loader.dart).
FR-06 | Trạng thái tin đi (Đã gửi/Đã nhận/Đã xem + biểu tượng) ở tin đi cuối nhóm | lib/ui/status_indicator.dart:StatusIndicator, statusLabel, statusIcon; gọi từ message_bubble.dart | – | test/status_test.dart | key status-<id>; id 13 seen, 30 delivered, 32 sent; 29/31 không hiện
FR-08 | Thanh nhập nhiều dòng (≤5) + nút gửi cục bộ, tin vào RAM, cuộn xuống cuối, không lưu | lib/ui/input_bar.dart:InputBar (keys input-field, send-button), lib/state/outbox.dart:Outbox, tích hợp chat_screen.dart:_ChatScreenState._onSend | – | test/input_bar_test.dart | id tin gửi từ 1000; rỗng/khoảng trắng thì nút vô hiệu; gom nhóm theo FR-03 nên status chỉ ở tin cuối; `lib/state/` thêm vào cấu trúc
FR-09/10 | Chủ đề sáng/tối theo hệ thống (ThemeMode.system) từ token; chữ 200% ở 360/412 dp không overflow; tương phản >=4,5:1 | lib/theme/app_theme.dart:AppTheme.light/dark, chat_colors.dart:ChatColors, contrastRatio; main.dart | – | test/theme/theme_test.dart, test/theme/contrast_extra_test.dart (thẻ, trạng thái, ô nhập, nút gửi) | NFR-02; test cuộn danh sách ở textScaler 2.0 cả sáng/tối
NFR-01/03 | Semantics bong bóng/thẻ (nhãn "Người gửi, nội dung, giờ, trạng thái", phần con bị loại khỏi cây a11y), nhãn ngày header, vùng chạm >=48dp | lib/ui/message_bubble.dart:messageSemanticsLabel, messageContentLabel; chat_screen.dart:_DayPill; input_bar.dart | – | test/a11y/semantics_test.dart | id 2/16/22/30 kiểm nhãn; ô nhập + nút gửi >=48 ở chữ 200%
REACT-01 | Trạng thái reaction cục bộ trong RAM (AC-R3,R6,R7): thêm/đổi/bỏ/toggle, một reaction mỗi người mỗi tin, đếm theo emoji; seed 3 tin (id 3,6,8) có reaction của peer; tin 3 có 4 emoji (peer, peer1..peer3) để kiểm chip xuống dòng chữ 200% (test/reaction_ui_test.dart) | lib/state/reactions.dart:ReactionStore, reactionEmojis (👍❤️😂😮😢🙏), seedReactions, reactionMeId | – | test/reactions_test.dart | UI nối ở dòng REACT-UI; không đổi chat-sample.json
FR-10/08 | Đáp ứng màn hình: 412x915, xoay ngang, bàn phím mở (AC-10.1, AC-10.3, AC-08.4) | lib/ui/chat_screen.dart | – | test/responsive_test.dart (ma trận 360x640/412x915 × chữ 100/200% × sáng/tối, không overflow) | DUMP: gỡ receiver androidx.profileinstaller qua tools:node=remove ở android/app/src/main/AndroidManifest.xml; ABI chỉ giới hạn bằng packaging excludes ở build.gradle.kts (abiFilters không đủ) | avatar peer #7A5C8E (trắng 5,6:1, NFR-02) ở assets/chat-sample.json
REACT-UI | Giao diện reaction (AC-R1..R4, R8..R12): long-press bong bóng/thẻ mở thanh 6 emoji (neo trên/dưới, kẹp 12dp, Wrap nhiều hàng khi hẹp); chip ngay dưới bong bóng, trên dòng giờ (Wrap chip cao 28dp, khe 4dp; ô chạm 48dp mở rộng ngoài layout bằng _ChipsHitArea hit-test, chồng nhau thì chip gần mép nhất, hòa thì chip trên/trái; chip của mình viền 2dp + số đậm; ô đang chọn trên thanh dùng reactionMineBg; Wrap spacing/runSpacing 4dp; action TalkBack anchor theo box bong bóng như long-press); nảy/fade <=180ms, tắt khi disableAnimations; Semantics tiếng Việt + custom action "Thả cảm xúc" | lib/ui/reactions/reaction_ui.dart:showReactionBar, ReactionBar, ReactionChips; tích hợp message_bubble.dart:MessageBubble(reactions), chat_screen.dart (ReactionStore); token reaction* trong lib/theme/chat_colors.dart | long-press tin | test/reaction_ui_test.dart | key reaction-bar, react-opt-<emoji>, chip-<id>-<emoji>; chip nằm giữa bong bóng và dòng giờ/trạng thái (design 2.2, test); reactions=null thì tắt tính năng

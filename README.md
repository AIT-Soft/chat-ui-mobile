# Chat UI Mobile

Ứng dụng Android (Flutter) hiển thị MỘT màn hình hội thoại hai người với dữ liệu mẫu hư cấu. Dùng làm mẫu thiết kế giao diện chat (bong bóng, gom nhóm tin, thẻ tệp/ảnh/liên kết, reaction, sáng/tối, chữ lớn, TalkBack). Đây **không phải** ứng dụng nhắn tin thật.

> Bản thiết kế mẫu – nội dung hư cấu. Mọi tên, tin nhắn, tệp và liên kết đều bịa; liên kết chỉ dùng `example.com`.

**Demo trực tuyến và APK demo:** https://chat-ui-demo.genalpha.dev
**Giấy phép:** [MIT](LICENSE) © Dương Tấn Thành

## Tính năng

- Một cuộc trò chuyện hai người: bong bóng căn trái/phải, gom nhóm tin, nhãn ngày, giờ HH:mm.
- Thẻ tệp, ảnh, liên kết (chỉ hiển thị); trạng thái tin đi Đã gửi / Đã nhận / Đã xem.
- Gửi tin cục bộ (đóng app là mất).
- Reaction: nhấn giữ tin để mở thanh 6 emoji; chip kèm số lượng; mỗi người một reaction mỗi tin; chỉ lưu trong RAM.
- Sáng/tối theo hệ thống, chữ hệ thống tới 200%, nhãn tiếng Việt cho trình đọc màn hình.
- Không gọi mạng; bản release không xin quyền INTERNET.

## Chạy và kiểm tra

Yêu cầu Flutter 3.47.2 (stable, Dart 3.13.2) và Android SDK. Chạy trong thư mục chứa `pubspec.yaml`:

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --debug
```

APK demo trên trang giới thiệu được ký bằng **khóa debug**. Build release dùng `android/key.properties` (không nằm trong git); thiếu tệp này thì ký khóa debug kèm cảnh báo.

## Cấu trúc

Xem [CODEMAP.md](CODEMAP.md) (cấu trúc thư mục, bảng tính năng, điểm mở rộng). Dữ liệu mẫu: `assets/chat-sample.json` (JSON 1.0, 32 tin).

## English

**Chat UI Mobile** is a Flutter (Android) UI template of a single two-person chat screen with fictional data: bubbles, message grouping, file/image/link cards, reactions, light/dark theme, large text and screen-reader labels. Not a real messaging app. Licensed under MIT. Demo and APK: https://chat-ui-demo.genalpha.dev (APK signed with the debug key).

## Liên hệ

Dương Tấn Thành – 039 736 4746. Donate hoàn toàn tùy tâm, xem trang giới thiệu.

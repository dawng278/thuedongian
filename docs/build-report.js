const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat, BorderStyle, WidthType,
  ShadingType, VerticalAlign, PageNumber, PageBreak, HeadingLevel,
  TableOfContents,
} = require("docx");

// ─── Helpers ────────────────────────────────────────────────────────────
const CONTENT_W = 9360; // US Letter, 1" margins

const border = { style: BorderStyle.SINGLE, size: 1, color: "B0B0B0" };
const cellBorders = { top: border, bottom: border, left: border, right: border };

function h1(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(text)] });
}
function h2(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });
}
function p(text, opts = {}) {
  return new Paragraph({
    spacing: { after: 120, line: 276 },
    alignment: AlignmentType.JUSTIFIED,
    children: [new TextRun({ text, ...opts })],
  });
}
// paragraph with mixed runs (bold lead-in + body)
function pRuns(runs) {
  return new Paragraph({
    spacing: { after: 120, line: 276 },
    alignment: AlignmentType.JUSTIFIED,
    children: runs.map((r) => new TextRun(r)),
  });
}
function bullet(text, runsBold) {
  return new Paragraph({
    numbering: { reference: "bullets", level: 0 },
    spacing: { after: 60, line: 264 },
    alignment: AlignmentType.JUSTIFIED,
    children: Array.isArray(text) ? text.map((r) => new TextRun(r)) : [new TextRun(text)],
  });
}
function numItem(runs) {
  return new Paragraph({
    numbering: { reference: "nums", level: 0 },
    spacing: { after: 60, line: 264 },
    alignment: AlignmentType.JUSTIFIED,
    children: Array.isArray(runs) ? runs.map((r) => new TextRun(r)) : [new TextRun(runs)],
  });
}

function tcell(content, { w, head = false, fill, bold = false, align } = {}) {
  const runs = Array.isArray(content) ? content : [content];
  return new TableCell({
    borders: cellBorders,
    width: { size: w, type: WidthType.DXA },
    verticalAlign: VerticalAlign.CENTER,
    shading: fill ? { fill, type: ShadingType.CLEAR } : undefined,
    margins: { top: 60, bottom: 60, left: 110, right: 110 },
    children: runs.map(
      (t) =>
        new Paragraph({
          alignment: align || AlignmentType.LEFT,
          children: [new TextRun({ text: t, bold: bold || head, size: head ? 20 : 20 })],
        })
    ),
  });
}

// rows: array of arrays of strings; widths: array of DXA
function makeTable(widths, headers, rows, headFill = "2E5E8C") {
  const headCells = headers.map((hh, i) =>
    new TableCell({
      borders: cellBorders,
      width: { size: widths[i], type: WidthType.DXA },
      verticalAlign: VerticalAlign.CENTER,
      shading: { fill: headFill, type: ShadingType.CLEAR },
      margins: { top: 60, bottom: 60, left: 110, right: 110 },
      children: [new Paragraph({ children: [new TextRun({ text: hh, bold: true, color: "FFFFFF", size: 20 })] })],
    })
  );
  const bodyRows = rows.map(
    (r, ri) =>
      new TableRow({
        children: r.map(
          (c, ci) =>
            new TableCell({
              borders: cellBorders,
              width: { size: widths[ci], type: WidthType.DXA },
              verticalAlign: VerticalAlign.CENTER,
              shading: ri % 2 === 1 ? { fill: "EEF3F8", type: ShadingType.CLEAR } : undefined,
              margins: { top: 50, bottom: 50, left: 110, right: 110 },
              children: [new Paragraph({ children: [new TextRun({ text: c, size: 20 })] })],
            })
        ),
      })
  );
  return new Table({
    width: { size: widths.reduce((a, b) => a + b, 0), type: WidthType.DXA },
    columnWidths: widths,
    rows: [new TableRow({ tableHeader: true, children: headCells }), ...bodyRows],
  });
}

function spacer() {
  return new Paragraph({ spacing: { after: 120 }, children: [new TextRun("")] });
}

// ─── Cover page ─────────────────────────────────────────────────────────
const cover = [
  new Paragraph({ spacing: { before: 1200, after: 120 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "IT SOLUTION CHALLENGE 2026", bold: true, size: 26, color: "2E5E8C" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 600 },
    children: [new TextRun({ text: "BÁO CÁO KỸ THUẬT", size: 24, color: "555555" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 600, after: 80 },
    children: [new TextRun({ text: "TaxEasy", bold: true, size: 72, color: "1B3A57" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 600 },
    children: [new TextRun({ text: "Trợ lý bán hàng & thuế cho hộ kinh doanh", bold: true, size: 30, color: "2E5E8C" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 120 },
    children: [new TextRun({ text: "Một ứng dụng điện thoại offline-first giúp hộ kinh doanh", italics: true, size: 22 })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 1000 },
    children: [new TextRun({ text: "bán hàng, quản lý doanh thu, ước tính thuế và xuất hóa đơn điện tử đúng luật 2026.", italics: true, size: 22 })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 60 },
    children: [new TextRun({ text: "Đội thi: 2 thành viên", size: 24, bold: true })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 60 },
    children: [new TextRun({ text: "Thành viên A — Ứng dụng Flutter   |   Thành viên B — Backend NestJS", size: 22 })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 400 },
    children: [new TextRun({ text: "Tháng 06 năm 2026", size: 24 })] }),
  new Paragraph({ children: [new PageBreak()] }),
];

// ─── TOC ────────────────────────────────────────────────────────────────
const toc = [
  new Paragraph({ spacing: { after: 200 }, children: [new TextRun({ text: "MỤC LỤC", bold: true, size: 32, color: "1B3A57" })] }),
  new TableOfContents("Mục lục", { hyperlink: true, headingStyleRange: "1-2" }),
  new Paragraph({ children: [new PageBreak()] }),
];

// ─── Body ───────────────────────────────────────────────────────────────
const body = [];

// 1. Mô tả bài toán
body.push(h1("1. Mô tả bài toán"));
body.push(h2("1.1. Bối cảnh: hộ kinh doanh phải tự kê khai thuế từ 2026"));
body.push(p(
  "Việt Nam có hàng triệu hộ kinh doanh cá thể (HKD) — quán ăn, cửa hàng tạp hóa, tiệm cà phê, dịch vụ nhỏ lẻ. " +
  "Trước đây, đa số nộp thuế theo phương pháp khoán: cơ quan thuế ấn định một mức cố định, người bán không cần ghi chép doanh thu. " +
  "Từ năm 2026, chính sách thay đổi căn bản: phương pháp thuế khoán bị bãi bỏ, hộ kinh doanh phải tự kê khai thuế dựa trên doanh thu thực tế. " +
  "Đồng thời, ngưỡng doanh thu được miễn thuế giá trị gia tăng (GTGT) và thuế thu nhập cá nhân (TNCN) được nâng từ 100 triệu lên 200 triệu đồng/năm " +
  "(Luật Thuế TNCN sửa đổi, thông qua ngày 10/12/2025, hiệu lực 01/01/2026)."
));
body.push(p(
  "Sự thay đổi này tạo ra một khoảng trống lớn: hàng triệu người vốn quen bán hàng bằng giấy bút và trí nhớ nay buộc phải " +
  "ghi nhận từng giao dịch, tổng hợp doanh thu theo kỳ, tính đúng tỷ lệ thuế theo loại hình, và xuất hóa đơn điện tử khi khách yêu cầu. " +
  "Họ thiếu cả công cụ lẫn kiến thức để làm việc này."
));
body.push(h2("1.2. Những nỗi đau cụ thể"));
body.push(bullet("Không có công cụ phù hợp: phần mềm bán hàng (POS) hiện có thường đắt, nặng, yêu cầu máy tính tiền và kết nối mạng ổn định — không hợp với một quán nhỏ chỉ có chiếc điện thoại."));
body.push(bullet("Bán hàng nơi sóng yếu: chợ, vỉa hè, khu vực sóng chập chờn khiến các ứng dụng yêu cầu online liên tục bị treo giữa lúc đông khách — mất đơn, mất khách."));
body.push(bullet("Không biết tính thuế: tỷ lệ thuế khác nhau theo loại hình (hàng hóa, ăn uống, dịch vụ); người bán không rõ mình đã gần ngưỡng 200 triệu hay chưa, không biết hạn nộp tờ khai."));
body.push(bullet("Hóa đơn điện tử rắc rối: chuẩn XML của Tổng cục Thuế phức tạp, người bán không thể tự tạo đúng cấu trúc."));
body.push(p(
  "TaxEasy ra đời để lấp đúng khoảng trống đó: một ứng dụng điện thoại duy nhất, hoạt động cả khi mất mạng, " +
  "gộp ba việc bán hàng — quản lý — thuế vào một luồng liền mạch, miễn phí và dễ dùng cho người không rành công nghệ."
));

// 2. Mục tiêu nghiên cứu
body.push(h1("2. Mục tiêu nghiên cứu"));
body.push(p("Đề tài hướng tới xây dựng một giải pháp phần mềm hoàn chỉnh, chạy thật được, với các mục tiêu cụ thể:"));
body.push(numItem("Xây dựng ứng dụng bán hàng offline-first: thao tác bán một món dưới 3 giây, hoạt động bình thường ngay cả khi không có mạng, và tự đồng bộ an toàn (không trùng, không mất đơn) khi có mạng trở lại."));
body.push(numItem("Tự động ước tính thuế đúng pháp luật 2026: tách tỷ lệ GTGT và TNCN theo loại hình hộ kinh doanh, áp dụng ngưỡng miễn thuế 200 triệu đồng/năm, cảnh báo khi gần ngưỡng và nhắc hạn kê khai theo quý."));
body.push(numItem("Xuất hóa đơn điện tử đúng chuẩn nhà nước: sinh file XML theo Thông tư 78/2021/TT-BTC, hiển thị mã QR để khách tra cứu."));
body.push(numItem("Cung cấp chế độ quản lý trực quan: doanh thu theo ngày/tháng/năm, biểu đồ, top sản phẩm bán chạy, lợi nhuận, cùng một bộ gợi ý thông minh giúp chủ quán ra quyết định."));
body.push(numItem("Đảm bảo chất lượng kỹ thuật: kiến trúc rõ ràng, có kiểm thử tự động cho các vùng nghiệp vụ quan trọng (đồng bộ, thuế, xác thực, xuất XML), và bảo mật cơ bản đúng chuẩn."));

// 3. Dữ liệu sử dụng
body.push(h1("3. Dữ liệu sử dụng"));
body.push(h2("3.1. Lược đồ cơ sở dữ liệu (6 bảng)"));
body.push(p("Hệ thống lưu trữ trên PostgreSQL thông qua ORM Prisma. Lược đồ gồm 6 bảng chính:"));
body.push(makeTable(
  [2000, 7360],
  ["Bảng", "Vai trò & ghi chú thiết kế"],
  [
    ["USER", "Tài khoản chủ hộ kinh doanh: email (duy nhất), mật khẩu băm bcrypt, tên. Một user sở hữu nhiều cửa hàng."],
    ["STORE", "Thông tin cửa hàng: tên, mã số thuế, địa chỉ, điện thoại, loại hình kinh doanh (goods | food_beverage | services). Là phạm vi (scope) cho toàn bộ dữ liệu nghiệp vụ."],
    ["PRODUCT", "Sản phẩm/món: tên, giá bán, giá vốn (tùy chọn — để tính lợi nhuận), tồn kho (tùy chọn), đơn vị, danh mục. Dùng is_active để xóa mềm và updated_at để versioning."],
    ["INVOICE", "Hóa đơn: id là UUID v4 sinh ở client (chống trùng khi đồng bộ), số hóa đơn tuần tự theo cửa hàng, tổng tiền, phương thức thanh toán (tiền mặt | chuyển khoản), thời điểm tạo và thời điểm đồng bộ."],
    ["INVOICE_ITEM", "Dòng hàng trong hóa đơn: lưu snapshot product_name và price tại thời điểm bán — bất biến, không đổi dù sản phẩm bị sửa giá hay xóa sau này."],
    ["PasswordResetOtp", "Mã OTP băm để khôi phục mật khẩu: email, hash OTP, hạn dùng, trạng thái đã dùng."],
  ]
));
body.push(spacer());
body.push(pRuns([
  { text: "Ba ràng buộc thiết kế quan trọng: ", bold: true },
  { text: "(1) INVOICE.id là UUID sinh ở client để chống trùng khi đồng bộ offline; (2) INVOICE_ITEM lưu snapshot tên + giá nên hóa đơn là bất biến (immutable) — đúng yêu cầu pháp lý; (3) PRODUCT dùng xóa mềm để hóa đơn cũ vẫn truy vết được sản phẩm đã bán." },
]));
body.push(h2("3.2. Dữ liệu mẫu (seed) cho demo"));
body.push(p(
  "Để chứng minh hệ thống vận hành với dữ liệu thực tế chứ không phải vài dòng giả lập, bộ seed dựng một cửa hàng mẫu " +
  "— quán “Mì Cay Seoul” — với menu thực tế (giá theo loại mì) và hơn 12.000 hóa đơn demo trải dài nhiều tháng. " +
  "Khối lượng này đủ để biểu đồ doanh thu, top sản phẩm, ước tính thuế theo kỳ và bộ gợi ý thông minh hoạt động trên số liệu có ý nghĩa."
));
body.push(h2("3.3. Nguồn pháp lý về thuế"));
body.push(makeTable(
  [4200, 5160],
  ["Văn bản", "Nội dung áp dụng trong hệ thống"],
  [
    ["Thông tư 18/2026/TT-BTC", "Tỷ lệ % thuế GTGT và TNCN theo loại hình HKD (thay thế Thông tư 40/2021/TT-BTC, hiệu lực 24/4/2026)."],
    ["Luật Thuế TNCN sửa đổi (thông qua 10/12/2025)", "Nâng ngưỡng doanh thu miễn thuế năm từ 100 lên 200 triệu đồng, hiệu lực 01/01/2026."],
    ["Thông tư 78/2021/TT-BTC", "Cấu trúc XML hóa đơn điện tử (mẫu số, ký hiệu, thông tin người bán, danh mục hàng hóa, tổng tiền)."],
  ]
));

// 4. Phương pháp thực hiện
body.push(h1("4. Phương pháp thực hiện"));
body.push(p("Các quyết định kỹ thuật cốt lõi đều xoay quanh một bài toán: bán hàng nơi sóng yếu mà tuyệt đối không được mất hay trùng hóa đơn."));
body.push(h2("4.1. Kiến trúc offline-first"));
body.push(p(
  "Ứng dụng coi offline là trạng thái mặc định, không phải ngoại lệ. Mỗi giao dịch bán hàng được ghi ngay vào cơ sở dữ liệu cục bộ trên máy " +
  "(SQLite qua sqflite) và hiển thị hóa đơn tức thì — không chờ mạng. Một hàng đợi đồng bộ (sync queue) giữ các hóa đơn chưa đẩy lên server; " +
  "khi có mạng, ứng dụng tự động gửi cả lô lên backend."
));
body.push(h2("4.2. UUID sinh ở client — chống trùng tận gốc"));
body.push(p(
  "Khóa chính của hóa đơn (INVOICE.id) là một UUID v4 được sinh ngay trên điện thoại tại thời điểm bán, chứ không phải do server cấp. " +
  "Nhờ vậy, dù một hóa đơn được gửi lại nhiều lần (do mất gói tin, bấm đồng bộ hai lần, hay hai thiết bị cùng đẩy), server nhận diện trùng theo id và bỏ qua bản sao. " +
  "Endpoint POST /sync/invoices vì thế có tính idempotent: gửi lại cùng một hóa đơn trả về trạng thái “duplicate” thay vì tạo bản ghi mới hay báo lỗi."
));
body.push(h2("4.3. Số hóa đơn tuần tự an toàn với truy cập đồng thời"));
body.push(p(
  "Mỗi cửa hàng cần dãy số hóa đơn liên tục 1, 2, 3… Cách tính ngây thơ “đếm số hóa đơn hiện có rồi cộng 1” không an toàn: hai hóa đơn đồng bộ cùng lúc " +
  "có thể đọc cùng một giá trị đếm, sinh ra hai hóa đơn trùng số và vi phạm ràng buộc duy nhất @@unique([store_id, invoice_number])."
));
body.push(pRuns([
  { text: "Giải pháp: ", bold: true },
  { text: "toàn bộ thao tác tạo hóa đơn được bọc trong một giao dịch (transaction) ở mức cô lập Serializable — mức cô lập cao nhất. " +
      "Khi xảy ra xung đột tuần tự (mã lỗi P2034) hoặc đụng ràng buộc duy nhất (P2002), hệ thống tự động thử lại tối đa 5 lần. " +
      "Đây là điểm khiến tính năng offline “chạy thật” thay vì chỉ là khẩu hiệu." },
]));
body.push(h2("4.4. Snapshot bất biến trên dòng hóa đơn"));
body.push(p(
  "Mỗi dòng hóa đơn (INVOICE_ITEM) lưu bản sao tên sản phẩm và giá tại đúng thời điểm bán. Nếu sau này chủ quán đổi giá hay xóa món, " +
  "hóa đơn cũ vẫn giữ nguyên con số đã in cho khách — đáp ứng yêu cầu hóa đơn không được thay đổi sau khi phát hành. " +
  "Để củng cố tính bất biến, mọi yêu cầu PATCH hoặc DELETE lên một hóa đơn đều bị từ chối với mã 405."
));

// 5. Kiến trúc hệ thống
body.push(h1("5. Kiến trúc hệ thống"));
body.push(h2("5.1. Tổng quan"));
body.push(p(
  "Hệ thống gồm một ứng dụng điện thoại Flutter (sản phẩm chính, không có bản web) và một backend NestJS + Prisma + PostgreSQL. " +
  "Ứng dụng có hai chế độ chuyển đổi bằng một nút: chế độ Bán hàng (mặc định, hoạt động offline) và chế độ Quản lý (doanh thu, thuế, lịch sử)."
));
body.push(new Paragraph({ spacing: { before: 60, after: 120 }, children: [
  new TextRun({ text: "Sơ đồ luồng dữ liệu:", bold: true }),
]}));
const diagram = [
  "┌─────────────────────────────────────────────────────────┐",
  "│              ỨNG DỤNG FLUTTER (điện thoại)                │",
  "│                                                          │",
  "│   ┌──────────────┐        ┌──────────────────────────┐   │",
  "│   │  Bán hàng    │        │      Quản lý             │   │",
  "│   │ lưới món,    │        │ doanh thu, biểu đồ,      │   │",
  "│   │ giỏ, QR      │        │ thuế, nhắc hạn, lịch sử  │   │",
  "│   └──────┬───────┘        └────────────┬─────────────┘   │",
  "│          │                             │                 │",
  "│   ┌──────▼─────────────────────────────▼─────────────┐   │",
  "│   │     SQLite cục bộ  +  Hàng đợi đồng bộ            │   │",
  "│   └──────────────────────┬───────────────────────────┘   │",
  "└──────────────────────────┼───────────────────────────────┘",
  "                           │  HTTP (dio) — khi có mạng",
  "                           │  POST /sync/invoices (idempotent)",
  "┌──────────────────────────▼───────────────────────────────┐",
  "│                 BACKEND NestJS                            │",
  "│  /auth  /stores  /products  /invoices  /sync             │",
  "│  /tax   /reports  /ai                                     │",
  "│                                                          │",
  "│  Transaction Serializable + retry  →  Prisma ORM         │",
  "└──────────────────────────┬───────────────────────────────┘",
  "                           │",
  "                  ┌────────▼────────┐",
  "                  │   PostgreSQL    │",
  "                  └─────────────────┘",
];
diagram.forEach((line) =>
  body.push(new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: line, font: "Courier New", size: 15 })] }))
);
body.push(spacer());

body.push(h2("5.2. Các màn hình của ứng dụng"));
body.push(p("Ứng dụng gồm 40 tệp Dart (~13.325 dòng), tổ chức theo bốn nhóm màn hình:"));
body.push(makeTable(
  [2200, 7160],
  ["Nhóm", "Màn hình"],
  [
    ["Xác thực (auth)", "Chào mừng, Onboarding, Đăng nhập, Đăng ký, Quên mật khẩu."],
    ["Bán hàng (sale)", "Màn bán hàng (lưới món + giỏ), Mã QR hóa đơn, Chờ đồng bộ (hàng đợi offline)."],
    ["Quản lý (manage)", "Doanh thu, Thuế ước tính, Nhắc hạn thuế, Top sản phẩm, Lịch sử hóa đơn, Quản lý sản phẩm, Tồn kho, Cài đặt cửa hàng, Hồ sơ, Sửa hồ sơ, Cài đặt ứng dụng, Trợ giúp."],
    ["Khung (home)", "Màn chính điều phối chuyển đổi giữa hai chế độ."],
  ]
));
body.push(spacer());

body.push(h2("5.3. Các nhóm API của backend"));
body.push(makeTable(
  [1700, 7660],
  ["Prefix", "Chức năng"],
  [
    ["/auth", "Đăng ký, đăng nhập, làm mới token (JWT); rate-limit từng route, mật khẩu băm bcrypt."],
    ["/stores", "Quản lý cửa hàng (một user có nhiều cửa hàng); kiểm tra quyền sở hữu."],
    ["/products", "CRUD sản phẩm; xóa mềm; cập nhật last-write-wins theo updated_at."],
    ["/invoices", "Lấy danh sách & chi tiết hóa đơn; xuất XML; chặn sửa/xóa (405)."],
    ["/sync", "Đẩy hàng đợi offline theo lô; idempotent theo UUID."],
    ["/tax", "Ước tính thuế theo kỳ; danh sách mốc hạn kê khai."],
    ["/reports", "Doanh thu tổng quan, biểu đồ theo ngày, top sản phẩm, tổng hợp kỳ."],
    ["/ai", "Bộ gợi ý thông minh (insight) cho chủ quán."],
  ]
));
body.push(spacer());

body.push(h2("5.4. Bảng tỷ lệ thuế theo loại hình"));
body.push(p("Logic thuế dùng chung một module (tax-rules) cho cả màn Thuế và dashboard, tránh lệch số liệu giữa hai nơi:"));
body.push(makeTable(
  [3400, 1600, 1600, 2760],
  ["Loại hình HKD", "GTGT", "TNCN", "Tổng tỷ lệ"],
  [
    ["Kinh doanh hàng hóa (goods)", "1,0%", "0,5%", "1,5%"],
    ["Ăn uống (food_beverage)", "3,0%", "1,5%", "4,5%"],
    ["Dịch vụ (services)", "5,0%", "2,0%", "7,0%"],
  ]
));
body.push(spacer());
body.push(pRuns([
  { text: "Ngưỡng miễn thuế: ", bold: true },
  { text: "doanh thu cả năm dưới 200 triệu đồng được miễn cả GTGT lẫn TNCN. Quan trọng là ngưỡng so sánh trên doanh thu " +
      "quy đổi cả năm (annualised), không phải doanh thu của riêng kỳ — ví dụ doanh thu một tháng được nhân 12 trước khi so với 200 triệu." },
]));

body.push(h2("5.5. Bộ gợi ý thông minh (AI insight engine)"));
body.push(p(
  "Thay vì gọi mô hình ngôn ngữ lớn (tốn chi phí, cần mạng, có độ trễ), TaxEasy dùng một bộ máy quy tắc (rule-based) gồm 15 quy tắc. " +
  "Bộ máy chạy hoàn toàn offline, thời gian xử lý dưới 1 mili-giây, không cần API key. Mỗi quy tắc xét bối cảnh cửa hàng (doanh thu, thuế, tồn kho, sản phẩm) " +
  "và sinh ra một gợi ý kèm độ ưu tiên; engine chọn ra 3 gợi ý ưu tiên cao nhất để hiển thị."
));
body.push(p("Một số quy tắc tiêu biểu (theo thứ tự ưu tiên giảm dần):"));
body.push(bullet("Cảnh báo nguy cơ vượt ngưỡng thuế khi doanh thu quy đổi năm đã đạt ≥ 90% của 200 triệu."));
body.push(bullet("Cảnh báo món đã hết kho (đang mất đơn) và món sắp hết kho."));
body.push(bullet("Cảnh báo doanh thu giảm mạnh (> 20% so với tháng trước) hoặc khích lệ khi tăng > 30%."));
body.push(bullet("Nhắc hạn kê khai vào tháng cuối quý; nhắc nhập mã số thuế để bật xuất hóa đơn; nhắc nhập giá vốn để tính lợi nhuận."));
body.push(bullet("Cảnh báo phụ thuộc một món (chiếm ≥ 60% doanh thu) — rủi ro tập trung."));

// 6. Kết quả đạt được
body.push(h1("6. Kết quả đạt được"));
body.push(h2("6.1. Số liệu định lượng"));
body.push(makeTable(
  [4860, 4500],
  ["Hạng mục", "Kết quả"],
  [
    ["Ứng dụng Flutter", "40 tệp Dart, ~13.325 dòng mã."],
    ["Backend NestJS", "~3.007 dòng TypeScript."],
    ["Kiểm thử tự động", "111 test PASS / 6 bộ test / 0 thất bại."],
    ["Build", "Cả ứng dụng và backend build thành công."],
    ["Di trú cơ sở dữ liệu (migration)", "8 migration Prisma được áp dụng tuần tự."],
    ["Dữ liệu demo", "Quán mẫu Mì Cay Seoul + hơn 12.000 hóa đơn."],
  ]
));
body.push(spacer());
body.push(p("Sáu bộ test bao phủ đúng các vùng nghiệp vụ rủi ro cao: đồng bộ (sync), thuế (tax-rules), nhắc hạn (tax deadlines), xác thực (auth), xuất XML, và bộ gợi ý (insight engine)."));

body.push(h2("6.2. Số liệu định tính"));
body.push(bullet("Tính thuế đúng luật 2026: áp dụng tỷ lệ theo loại hình và ngưỡng miễn 200 triệu/năm, có dẫn nguồn văn bản pháp lý ngay trong phản hồi API."));
body.push(bullet("Xuất XML đúng chuẩn Thông tư 78/2021/TT-BTC: cấu trúc HDon / DLHDon / NDHDon / TToan đầy đủ, có vùng chữ ký số để trống đúng quy cách."));
body.push(bullet("Chạy offline thật: bán hàng khi tắt mạng vẫn ra hóa đơn; bật mạng tự đồng bộ; cơ chế UUID + transaction Serializable + retry bảo đảm không trùng số hóa đơn kể cả khi hai thiết bị đẩy đồng thời."));

body.push(h2("6.3. Demo trọn chuỗi (definition of done)"));
body.push(p("Hệ thống chạy liền mạch toàn bộ chuỗi nghiệp vụ trên một chiếc điện thoại:"));
body.push(numItem("Đăng nhập vào ứng dụng, mở thẳng chế độ Bán hàng."));
body.push(numItem("Chạm món để bán — thao tác dưới 3 giây; chọn tiền mặt, app tính tiền thối; hiển thị mã QR hóa đơn cho khách."));
body.push(numItem("Tắt mạng (chế độ máy bay) — vẫn bán bình thường, hóa đơn lưu cục bộ, không mất đơn."));
body.push(numItem("Bật mạng trở lại — ứng dụng tự đồng bộ, số đơn chờ về 0, không trùng số hóa đơn."));
body.push(numItem("Chuyển sang chế độ Quản lý — xem doanh thu (tách tiền mặt/chuyển khoản), biểu đồ tuần/tháng/năm, top món, lợi nhuận."));
body.push(numItem("Mở màn Thuế — ước tính GTGT + TNCN theo luật 2026, cảnh báo khi gần ngưỡng 200 triệu, nhắc hạn nộp tờ khai quý."));
body.push(numItem("Vào Lịch sử hóa đơn, chọn một hóa đơn và xuất file XML đúng chuẩn Thông tư 78/2021."));

body.push(h2("6.4. So sánh với các giải pháp/đội thi thông thường"));
body.push(makeTable(
  [2400, 3480, 3480],
  ["Yếu tố", "Đa số giải pháp", "TaxEasy"],
  [
    ["Offline", "Hô khẩu hiệu, không chạy thật", "UUID client + transaction Serializable + retry — chạy thật, chống trùng"],
    ["Hóa đơn điện tử", "Bỏ qua hoặc giả lập", "Xuất XML đúng Thông tư 78/2021"],
    ["Tính thuế", "Hardcode một con số", "Đúng luật 2026, tách theo loại hình, ngưỡng 200 triệu"],
    ["Bảo mật", "Để JWT secret trong mã", "Fail-fast, bcrypt, rate-limit từng route, kiểm tra quyền sở hữu"],
    ["Kiểm thử", "Gần như không có", "111 test PASS trên 6 bộ test"],
  ]
));
body.push(spacer());
body.push(pRuns([
  { text: "Ba điểm phân biệt cốt lõi (USP): ", bold: true },
  { text: "(1) offline-first chạy thật và có chống trùng hóa đơn; (2) tính thuế đúng pháp luật 2026; (3) xuất hóa đơn XML đúng chuẩn nhà nước. " +
      "Ba điểm này biến TaxEasy từ một bản demo thành một sản phẩm dùng được ngay." },
]));

// 7. Hướng phát triển
body.push(h1("7. Hướng phát triển"));
body.push(p("Trên nền tảng hiện có, hệ thống có thể mở rộng theo các hướng sau, xếp theo giá trị thực tế cho hộ kinh doanh:"));
body.push(numItem("Quét QR/mã vạch để nhập hàng nhanh: dùng camera điện thoại quét mã sản phẩm khi nhập kho, giảm nhập liệu thủ công."));
body.push(numItem("Nối Claude API cho lời khuyên ngôn ngữ tự nhiên: bổ sung lên trên bộ quy tắc 15 rule một lớp tư vấn bằng ngôn ngữ tự nhiên, diễn giải số liệu thành lời khuyên dễ hiểu cho chủ quán."));
body.push(numItem("Xuất báo cáo thuế PDF theo mẫu 01/CNKD: điền sẵn số liệu vào tờ khai chuẩn để hộ kinh doanh in và nộp trực tiếp."));
body.push(numItem("Đa cửa hàng / nhiều nhân viên: phân quyền theo vai trò, quản lý nhiều chi nhánh trên cùng một tài khoản."));
body.push(numItem("Tích hợp cổng hóa đơn điện tử quốc gia: gửi thẳng hóa đơn XML đã ký số lên hệ thống của Tổng cục Thuế."));
body.push(spacer());
body.push(p(
  "TaxEasy hiện đã hoàn thiện phần lõi: một ứng dụng bán hàng offline-first, tính thuế đúng luật 2026 và xuất hóa đơn điện tử chuẩn nhà nước, " +
  "được kiểm chứng bằng demo trọn chuỗi và 111 test tự động. Đây là nền tảng vững để phát triển thành một sản phẩm thương mại phục vụ hàng triệu hộ kinh doanh Việt Nam.",
  { italics: true }
));

// ─── Document ───────────────────────────────────────────────────────────
const doc = new Document({
  creator: "TaxEasy Team",
  title: "Báo cáo kỹ thuật TaxEasy",
  styles: {
    default: { document: { run: { font: "Arial", size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 30, bold: true, color: "1B3A57", font: "Arial" },
        paragraph: { spacing: { before: 320, after: 160 }, outlineLevel: 0, keepNext: true } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 25, bold: true, color: "2E5E8C", font: "Arial" },
        paragraph: { spacing: { before: 220, after: 100 }, outlineLevel: 1, keepNext: true } },
    ],
  },
  numbering: {
    config: [
      { reference: "bullets", levels: [{ level: 0, format: LevelFormat.BULLET, text: "•",
        alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 280 } } } }] },
      { reference: "nums", levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.",
        alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 280 } } } }] },
    ],
  },
  sections: [
    // Cover (no footer page number)
    {
      properties: { page: { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
      children: cover,
    },
    // TOC + body with footer
    {
      properties: { page: { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
      footers: {
        default: new Footer({
          children: [new Paragraph({ alignment: AlignmentType.CENTER, border: { top: { style: BorderStyle.SINGLE, size: 4, color: "B0B0B0", space: 6 } },
            children: [new TextRun({ text: "TaxEasy — Báo cáo kỹ thuật · IT Solution Challenge 2026 · Trang ", size: 16, color: "777777" }),
              new TextRun({ children: [PageNumber.CURRENT], size: 16, color: "777777" })] })],
        }),
      },
      children: [...toc, ...body],
    },
  ],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync("/home/dawngbeo/school-project/ThueDonGian/docs/BaoCao_KyThuat_TaxEasy.docx", buf);
  console.log("WROTE docx, bytes:", buf.length);
});

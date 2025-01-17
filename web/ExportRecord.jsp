<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="static java.awt.SystemColor.window" %>

<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");
  String exportType = request.getParameter("exportType");
  String[] selectedRecords = request.getParameterValues("selectedRecords");

  if (selectedRecords != null && selectedRecords.length > 0) {
    // 保存选中的记录
    List<String[]> recordsToExport = new ArrayList<>();

    // 解析选中的记录
    for (String record : selectedRecords) {
      String[] recordDetails = record.split("\\|");
      // 确保数组长度至少为5（包括fileName）
      if (recordDetails.length >= 5) {
        recordsToExport.add(new String[] {
                recordDetails[0], // username
                recordDetails[1], // receiver
                recordDetails[2], // message
                recordDetails[3], // date
                recordDetails[4]  // fileName
        });
      }
    }

    if ("txt".equals(exportType)) {
      // 生成TXT文件
      response.setContentType("text/plain; charset=UTF-8");
      response.setHeader("Content-Disposition", "attachment;filename=chat_records.txt");
      for (String[] record : recordsToExport) {
        out.println("发送人: " + record[0] + " | 接收人: " + record[1] + " | 消息: " + record[2] + " | 附件: " + record[4] + " | 日期: " + record[3]);
      }
    } else if ("csv".equals(exportType)) {
      // 生成CSV文件
      response.setContentType("text/csv; charset=UTF-8");
      response.setHeader("Content-Disposition", "attachment;filename=chat_records.csv");
      out.println("发送人,接收人,消息,附件,日期");
      for (String[] record : recordsToExport) {
        // 对于 CSV，需要对文本中可能出现的双引号进行转义
        String sender = record[0].replace("\"", "\"\"");
        String receiver = record[1].replace("\"", "\"\"");
        String message = record[2].replace("\"", "\"\"");
        String attachment = record[4] != null ? record[4].replace("\"", "\"\"") : "";
        String date = record[3].replace("\"", "\"\"");
        out.println("\"" + sender + "\",\"" + receiver + "\",\"" + message + "\",\"" + attachment + "\",\"" + date + "\"");
      }
    } else if ("excel".equals(exportType)) {
      // 生成Excel (实际上是制表符分隔的文本文件，Excel可正常打开)
      response.setContentType("application/vnd.ms-excel; charset=UTF-8");
      response.setHeader("Content-Disposition", "attachment;filename=chat_records.xls");
      // 输出表头
      out.println("发送人\t接收人\t消息\t附件\t日期");
      for (String[] record : recordsToExport) {
        String sender = record[0].replace("\t", " ");
        String receiver = record[1].replace("\t", " ");
        String message = record[2].replace("\t", " ");
        String attachment = record[4] != null ? record[4].replace("\t", " ") : "";
        String date = record[3].replace("\t", " ");
        out.println(sender + "\t" + receiver + "\t" + message + "\t" + attachment + "\t" + date);
      }
    } else {
      out.println("不支持的导出格式");
    }
  } else {
    out.println("没有选择记录进行导出");
    // 使用history对象的back方法返回上一页
    String referer = request.getHeader("Referer");
    response.sendRedirect(referer);
  }
%>

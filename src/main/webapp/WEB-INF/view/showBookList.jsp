<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="ja">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MyBooks</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" />
<script src="<%=request.getContextPath()%>/js/jquery-3.6.0.min.js"></script>
</head>
<div id="sizeJudgment">
	<c:if test="${empty bookList}">
		<% response.sendRedirect("noBook"); %>
	</c:if>
</div>
<body>
	<h1>Book List</h1>
	<div id="userInput">
		<p>
			ISBN: <input type="number" id="isbnCode" autofocus> 現在のページ: <input
				type="number" id="currentPage" min="0" value="0">
			<button id="btn" type="button" class="btn btn-primary">追加</button>
			<button id="readingBooks" type="button" class="btn btn-info">現在進行中</button>
			<button id="allBooks" type="button" class="btn btn-info" style="display: none;">すべて表示</button>
		</p>
	</div>
	<!-- テーブルをc:forEachで記述する -->
	<table id="bookTable" class="table table-striped">
		<thead>
			<tr class="headLine">
				<th class="hCover">表紙</th>
				<th class="hTitle">タイトル</th>
				<th class="hAuthors">著者</th>
				<th class="hPageCount">ページ</th>
				<th class="hBookmark">ブックマーク</th>
				<th class="hProgress">進捗</th>
				<th class="hFinished">読了</th>
			</tr>
		</thead>
			<c:forEach items="${bookList}" var="book" varStatus="vs">
			<tbody id="${'tbody' += vs.count}" class="tbodyClass">
				<tr class="row1">
					<td class="cover" rowspan="2"><!-- 表紙 -->
						<img src="<c:out value="${empty book.cover? '../images/NoImage.png': book.cover}"/>"
						alt="BOOK COVER" /></td>
					<td class="title">
						<!-- タイトル --> <c:out value="${book.title}" />
					</td>
					<td class="authors">
						<!-- 著者 --> <c:out value="${book.authors}" />
					</td>
					<td class="pageCount">
						<!-- ページ数 --> <c:out value="${book.pageCount}" />
					</td>
					<td>
						<!-- ブックマーク --> <input type="number" class="readingPage"
						min="0" value="<c:out value="${book.bookmark}" />">
						<button type="button" class="update btn btn-info"
							data-id="${book.id}">更新</button>
					</td>
					<td class="Progress">
						<!-- 進捗 --> <fmt:formatNumber
							value="${book.bookmark / book.pageCount * 100}" pattern="##0.0" />
						%
					</td>
					<td>
						<!-- 読了 -->
						<button type="button" class="finished btn btn-warning"
							data-id="${book.id}">読了</button>
					</td>
				</tr>
				<tr class="row2">
					<td id="description${vs.index}" class="description" colspan="6">
						<!-- 概要 --> <c:out value="${book.description}" />
					</td>
					<td id="${vs.index}" class="registeredIsbn" style="display: none;"><c:out
							value="${book.isbn}" /></td>
				</tr>
			</tbody>
		</c:forEach>
	</table>
<script src="../js/MyBooksJS.js"></script>
</body>
</html>
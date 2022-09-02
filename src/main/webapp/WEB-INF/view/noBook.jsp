<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>No Book</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" />
<script src="<%=request.getContextPath()%>/js/jquery-3.6.0.min.js"></script>
</head>
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
	<h3>本が登録されていません。</h3>
	<script src="<%=request.getContextPath()%>/js/MyBooksJS.js"></script>
</body>
</html>
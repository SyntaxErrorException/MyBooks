<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="ja">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MyBooks</title>
<link rel="stylesheet"
	href="<%= request.getContextPath() %>/css/bootstrap.min.css" />
<link rel="stylesheet"
	href="<%= request.getContextPath() %>/css/style.css" />
</head>

<body>
	<h1>Book List</h1>
	<div>
		ISBN: <input type="text" id="isbnCode">
		現在のページ: <input type="number" id="currentPage" min="0" value="0">
		<button id="btn">追加</button>
	</div>

	<!-- テーブルをc:forEachで記述する -->
	<table id="book-table">
		<c:forEach items="${bookList}" var="book" varStatus="vs">
			<tr style="height: 20px;">
				<td id="cover" rowspan="2">
					<!-- 表紙 --> <c:out value="${book.cover}" />
				</td>
				<td id="title">
					<!-- タイトル --> <c:out value="${book.title}" />
				</td>
				<td id="authors">
					<!-- 著者 --> <c:out value="${book.authors}" />
				</td>
				<td id="pageCount">
					<!-- ページ数 --> <c:out value="${book.pageCount}" />
				</td>
				<td><input type="number" id="pageRead" min="0"
					value="<c:out value="${book.pageRead}" />">
					<button id="update">更新</button></td>
				<td id="progress">
					<!-- 進捗 --> 進捗:<fmt:formatNumber
						value="${book.pageRead / book.pageCount * 100}" />%
				</td>
				<td>
					<button id="finished">読了</button>
				</td>
			</tr>
			<tr>
				<td id="description" colspan="6">
					<!-- 概要 --> <c:out value="${book.description}" />
				</td>
			</tr>
		</c:forEach>
	</table>

	<!-- テーブル行のテンプレート -->
	<template id="book-row-template">
		<tr style="height: 20px;">
			<td id="cover" rowspan="2">
				<!-- 表紙 -->
			</td>
			<td id="title">
				<!-- タイトル -->
			</td>
			<td id="authors">
				<!-- 著者 -->
			</td>
			<td id="pageCount">
				<!-- ページ数 -->
			</td>
			<td><input type="number" id="pageRead" min="0">
				<button id="update">更新</button></td>
			<td id="progress">
				<!-- 進捗 -->
			</td>
			<td>
				<button id="finished">読了</button>
			</td>
		</tr>
		<tr>
			<td id="description" colspan="6">
				<!-- 概要 -->
			</td>
		</tr>
	</template>

	<script src="<%= request.getContextPath() %>/js/jquery-3.6.0.min.js"></script>
	<script>
    /**
     * Book List テーブルの1冊分を生成する関数
     * @param プロパティとしてtitle,authors,pageCount,discription,smallTumbnailを持つ
     * @return 本のデータが入ったtr要素
     */
                function createRow(book) {
                    // テンプレートの要素(1冊分のHTML)を複製
                    const clone = $($('#book-row-template').html());
                    
                    // 行ごとのtd要素にデータを追加
                    try {
                        clone.find('#cover').append('<img src=\"' + book.items[0]
                            .volumeInfo.imageLinks.smallThumbnail + '\" />');
                    } catch {
                    	clone.find('#cover').append('');
                    }
                    clone.find('#title').append(book.items[0].volumeInfo.title);
                    clone.find('#authors').append(book.items[0].volumeInfo.authors);
                    clone.find('#pageCount').append(book.items[0].volumeInfo.pageCount);
                    clone.find('#progress').append('進捗:' +
                        Math.round($('#currentPage').val() / book.items[0].volumeInfo.pageCount * 100) + '%');
                    clone.find('#description').append(book.items[0].volumeInfo.description);
                    clone.find('#pageRead').val($('#currentPage').val());

                    //行を削除
                    clone.find('#finished').click(function () {
                        $(this).parent().parent().next().remove();
                        $(this).parent().parent().remove();
                    });

                    //進捗を更新
                    clone.find('#update').click(function () {
                        $(this).parent().next().text(
                            '進捗:' + Math.round($(this).prev().val() / $(this).parent().prev().text() * 100) + '%');
                    });
                    
                    return clone;
                }
                
                // メインの処理
                $(document).ready(function () {
                    $('#btn').click(function () {
                        const isbnCode = $('#isbnCode').val();
                        const endpoint = 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbnCode;
                        $.ajax({
                            url: endpoint,
                            type: 'GET',
                            dateType: JSON
                        })//ajax
                            .done(function (res) {
                                // 取得したデータの確認
                                console.log(res);

                                if (res.totalItems == 1) {
                                    // テーブルに行を追加
                                    $('#book-table').prepend(createRow(res));
                                    
                                    let cover = '';
                                    try {
                                    	cover = res.items[0].volumeInfo.imageLinks.smallThumbnail;
                                    } catch {
                                    	cover = '';
                                    }
                                    
                                    const data = {
                                    	title: res.items[0].volumeInfo.title,
                                    	authors: res.items[0].volumeInfo.authors[0],
                                    	pageCount: res.items[0].volumeInfo.pageCount,
                                    	description: res.items[0].volumeInfo.description,
                                    	isbn: $('#isbnCode').val(),
                                    	readPage: $('#currentPage').val(),
                                    	cover: cover
                                    };
                                    
                                    sendToServlet(data);
                                } else {
                                    alert('totalItems:' + res.totalItems + '\r\n検索結果が複数のため追加できません。');
                                }
                            })//done
                            .fail(function () {
                                $('#inputISBN').after('<p>データの取得に失敗しました。</p>')
                            });//fail
                    });//click
                    
                });//ready
                    
                function sendToServlet(dataToSend){
                   	  $.ajax({
	                     url: 'http://localhost:8080/MyBooks/members/showBookList',
	                     type: 'POST',
	                     data: dataToSend
	                  })//ajax
	                 .done(function(res){

	                  })//done                    	
	                  .fail(function(){
	                	  
	                  });//fail
                }
	</script>
</body>
</html>
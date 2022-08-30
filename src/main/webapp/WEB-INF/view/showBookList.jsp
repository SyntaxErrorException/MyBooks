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
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/bootstrap.min.css" />
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/style.css" />
<script src="<%=request.getContextPath()%>/js/jquery-3.6.0.min.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery.easing.min.js"></script>
</head>

<body>
	<h1>Book List</h1>
	<p>
		ISBN: <input type="text" id="isbnCode" autofocus> 現在のページ: <input
			type="number" id="currentPage" min="0" value="0">
		<button id="btn">追加</button>
		<button id="switchView">現在進行中</button>
		<button id="reload" style="display: none;">すべて表示</button>
	</p>

	<!-- テーブルをc:forEachで記述する -->
	<table id="book-table">
		<c:set var="listSize" value="${fn:length(bookList)}" />
		<c:forEach items="${bookList}" var="book" varStatus="vs">
			<tr class="record" style="height: 20px;">
				<td id="cover" rowspan="2">
					<div class="record">
						<!-- 表紙 -->
						<img src="<c:out value="${book.cover}" />" alt="BOOK COVER" />
					</div>
				</td>
				<td id="title">
					<div class="record">
						<!-- タイトル -->
						<c:out value="${book.title}" />
					</div>
				</td>
				<td id="authors">
					<div class="record">
						<!-- 著者 -->
						<c:out value="${book.authors}" />
					</div>
				</td>
				<td id="pageCount">
					<div class="record">
						<!-- ページ数 -->
						<c:out value="${book.pageCount}" />
					</div>
				</td>
				<td>
					<div class="record">
						<!-- ブックマーク -->
						<input type="number" class="readingPage" min="0"
							value="<c:out value="${book.bookmark}" />">
						<button id="update"
							onclick="update(<c:out value="${book.id += ','}"/>$(this).prev().val())">更新</button>
					</div>
				</td>
				<td id="progress">
					<div class="record">
						<!-- 進捗 -->
						進捗:
						<fmt:formatNumber value="${book.bookmark / book.pageCount * 100}"
							pattern="##0" />
						%
					</div>
				</td>
				<td>
					<div class="record">
						<!-- 読了 -->
						<button id="finished"
							onclick="finished(<c:out value="${book.id}"/>)">読了</button>
					</div>
				</td>
			</tr>
			<tr class="record">
				<td id="description" colspan="6">
					<div class="record">
						<!-- 概要 -->
						<c:out value="${book.description}" />
					</div>
				</td>
				<td class="registeredIsbn" style="display: none;">
					<div class="record">
						<c:out value="${book.isbn}" />
					</div>
				</td>
			</tr>
		</c:forEach>
	</table>

	<!-- テーブル行のテンプレート開始 -->
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
			<td>
				<!-- ブックマーク --> <input type="number" id="bookmark" min="0">
				<button id="update">更新</button>
			</td>
			<td id="progress">
				<!-- 進捗 -->
			</td>
			<td>
				<!-- 読了 -->
				<button id="finished">読了</button>
			</td>
		</tr>
		<tr>
			<td id="description" colspan="6">
				<!-- 概要 -->
			</td>
			<td id="registeredIsbn" class="registeredIsbn" style="display: none;">
			</td>
		</tr>
	</template>
	<!-- テーブル行のテンプレート終了 -->

	<script>
	// 読了ボタンクリックで行を削除する
	function finished(id){
        //レコード削除のサーブレットへ誘導
        window.location.href = '/MyBooks/members/finished?id=' + id;
        console.log('削除完了');
	}
	
	// 更新ボタンクリックで進捗を更新する
	function update(id,num){
		//レコード更新のサーブレットへ誘導
		window.location.href = '/MyBooks/members/update?id=' + id + '&page=' + num;
        console.log('更新完了');
	}
	
	// 登録済みのISBNとの重複をチェックする
	function duplication(){
    	const registeredIsbn = document.getElementsByClassName('registeredIsbn');
    	if (registeredIsbn.length > 0) {
        	for (let isbn of registeredIsbn) {
            	if (isbn.textContent.trim() == $('#isbnCode').val()) {
                	// ISBNの重複があれば確認アラートを表示する
            		const answer = confirm("登録済みのISBNです。\r\nもう１冊、登録しますか？");
            		if (!answer) {
                		//「いいえ」なら入力欄をクリアして中断
                		$('#isbnCode').val('');
                		$('#currentPage').val('0');
                		return false;
            		} else {
                		return true;
                	}
            	}
        	}
        }
	}
	
    /**
     * Book List テーブルの1冊分を生成する関数
     * @param プロパティとしてtitle,authors,pageCount,discription,smallTumbnailを持つ
     * @return 本のデータが入ったtr要素
     */
                function createRow(book) {
                    // テンプレートの要素(1冊分のHTML)を複製
                    const clone = $($('#book-row-template').html());
                    
                    /**
                    *表紙用の変数にサムネイルを格納
                    *古い本の場合、プロパティが存在しないのでtry-catchで囲む
                    */
                    try {
                        clone.find('#cover').append('<img src=\"' + book.items[0]
                            .volumeInfo.imageLinks.smallThumbnail + '\" />');
                    } catch {
                    	clone.find('#cover').append('');
                    }
                    
                    //共著の場合に対応するための処理
                    let authorsList = '';
                    if (book.items[0].volumeInfo.authors.length > 1) {
                    	book.items[0].volumeInfo.authors.forEach(e => authorsList += e + '・');
                    	authorsList = authorsList.replace(/・$/,"");
                    } else {
                        authorsList = book.items[0].volumeInfo.authors[0];
                    }
                    
                    // td要素にデータを追加
                    clone.find('#title').append(book.items[0].volumeInfo.title);
                    clone.find('#authors').append(authorsList);
                    clone.find('#pageCount').append(book.items[0].volumeInfo.pageCount);
                    clone.find('#progress').append('進捗:' +
                        Math.round($('#currentPage').val() / book.items[0].volumeInfo.pageCount * 100) + '%');
                    clone.find('#description').append(book.items[0].volumeInfo.description);
                    clone.find('#bookmark').val($('#currentPage').val());
                    clone.find('#isbn').val($('#isbnCode').val());

                    // 読了した本を削除
                    clone.find('#finished').click(function () {
                        $(this).parent().parent().next().remove();
                        $(this).parent().parent().remove();
                    });

                    // 進捗を更新
                    clone.find('#update').click(function () {
                    	const bookmark = $(this).parent().prev().text();
                        $(this).parent().next().text(
                            '進捗:' + Math.round($(this).prev().val() / bookmark * 100) + '%');
                    });
                                        
                    return clone;
                }
                
                /*
                追加ボタン押下時の処理
                テーブルに一冊分のデータを追加する
                */
                $(document).ready(function () {
                    $('#btn').click(function () {
                    	// 登録済みISBNとの重複を調査する
                    	if (!duplication()){
                    		return;
                    	}
                    	
                    	// 「はい」なら一冊分のデータを追加する
                        const isbnCode = $('#isbnCode').val();
                        const endpoint = 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbnCode;
                        $.ajax({
                            url: endpoint,
                            type: 'GET',
                            dateType: JSON
                        })// ajax
                            .done(function (res) {
                                // 取得したデータの確認
                                console.log(res);

                                if (res.totalItems == 1) {
                                    // テーブルに行を追加
                                    $('#book-table').prepend(createRow(res));

                                    /*
                                    表紙用の変数にサムネイルを格納
                                    古い本の場合、プロパティが存在しないのでtry-catchで囲む
                                    */
                                    let cover = '';
                                    try {
                                    	cover = res.items[0].volumeInfo.imageLinks.smallThumbnail;
                                    } catch(e) {
                                    	cover = '';
                                    	console.log(e);
                                    }

                                    //共著の著者名に対応するための処理
                                    let authorsList = '';
                                    if (res.items[0].volumeInfo.authors.length > 1) {
                                    	res.items[0].volumeInfo.authors.forEach(e => authorsList += e + '・');
                                    	authorsList = authorsList.replace(/・$/,"");
                                    } else {
                                        authorsList = res.items[0].volumeInfo.authors[0];
                                    }

                                    //JSONからJavaScriptオブジェクトへ変換
                                    const objJS = {
                                    	title: res.items[0].volumeInfo.title,
                                    	authors: authorsList,
                                    	pageCount: res.items[0].volumeInfo.pageCount,
                                    	description: res.items[0].volumeInfo.description,
                                    	isbn: isbnCode,
                                    	bookmark: $('#currentPage').val(),
                                    	cover: cover
                                    };
                                    
                                    // 入力フォームをクリア
                                    $('#isbnCode').val('');
                                    $('#currentPage').val('0');
                                    
                                    sendToBookList(objJS);
                                    
                                    location.reload();
                                    
                                } else {
                                    alert('totalItems:' + res.totalItems + '\r\n検索結果が1冊ではないので追加できません。');
                                }
                            })//done
                            .fail(function () {
                                $('#inputISBN').after('<p>データの取得に失敗しました。</p>')
                            });//fail
                    });//click
                    
                	// 現在進行中の本のみ表示する
                	$('#switchView').click(function(){
	                	const readingPage = document.getElementsByClassName('readingPage');
                		// ブックマークのクラス属性を使って現在進行中か否かを判断する
                		let i = 1;
                		for (let r of readingPage){
                			if (r.value == 0) {
                				//表示を消す
                				$('tr:nth-child(' + i + ')').css('display','none');
                				$('tr:nth-child(' + i + ')').next().css('display','none');
                				$('#switchView').css('display','none');
                				$('#reload').css('display','inline');
                			}
                			i += 2;
                		}
                		console.log('表示完了');
                	});
                    
                    //すべて表示
                    $('#reload').click(function(){
                    	window.location.reload();
        				$('#reload').css('display','none');
                    	$('#switchView').css('display','inline');
                    })
                });//ready

                // ShowBookListサーブレットにJSONから変換したJSオブジェクトを送る    
                function sendToBookList(bookData){
                   	  $.ajax({
	                     url: 'http://localhost:8080/MyBooks/members/showBookList',
	                     type: 'POST',
	                     data: bookData
	                  })//ajax
	                 .done(function(res){
	                	  console.log("登録成功");
	                  })//done                    	
	                  .fail(function(){
	                	  console.log("登録失敗");
	                  });//fail
                }
	</script>
</body>
</html>
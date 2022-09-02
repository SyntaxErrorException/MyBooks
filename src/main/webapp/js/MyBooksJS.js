//追加ボタン押下時の処理
//テーブルに一冊分のデータを追加する
//重複登録の確認
//ISBNの重複があれば確認アラートを表示する
$(document).ready(function () {
    $('#btn').click(function () {
        // 登録済みISBNとの重複を調査する
        //「もう1冊、登録しますか？」に「いいえ」ならばリターン
        const bool = duplication();
        if (bool){
            const result = confirm("登録済みのISBNです。\r\nもう１冊、登録しますか？");
            if (result === false) return;
        }
        //「はい」なら一冊分のデータを追加する
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

                if (Number(res.totalItems) === 1) {
                    /*
                    表紙用の変数にサムネイルを格納
                    古い本の場合、プロパティが存在しないのでtry-catchで囲む
                    */
                    let cover = null;
                    try {
                        cover = res.items[0].volumeInfo.imageLinks.smallThumbnail;
                    } catch(e) {
                        console.log(e);
                    }

                    //共著の著者名を連結
                    //"・"を著者名の間に挟む
                    //行末の"・"は削除
                    let authorsList = '';
                    if (res.items[0].volumeInfo.authors.length > 1) {
                        res.items[0].volumeInfo.authors.forEach(e => authorsList += e + '・');
                        authorsList = authorsList.replace(/・$/,'');
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
                    
                } else {
                    alert('totalItems:' + res.totalItems + '\r\n検索結果が複数あります。入力を見直してください。');
                }
            })//done
            .fail(function () {
                $('#inputISBN').after('<p>データの取得に失敗しました。</p>')
            });//fail
    });//click
});//ready

// ShowBookListサーブレットにJSONから変換したJSオブジェクトを送る    
function sendToBookList(bookData){
    $.ajax({
    url: 'http://localhost:8080/MyBooks/members/showBookList',
    type: 'POST',
    data: bookData
    })
    .done(function(res){
        console.log("登録成功");
        window.location.href = "http://localhost:8080/MyBooks/members/showBookList";
    })                    	
    .fail(function(){
    alert("登録失敗です。");
    console.log("登録失敗");
    });
}//sendToBookList
    
// 登録済みのISBNとの重複をチェックする
function duplication(){
    const registeredIsbn = document.getElementsByClassName('registeredIsbn');
    if (registeredIsbn.length > 0) {
        for (let isbn of registeredIsbn) {
            if (isbn.textContent.trim() === $('#isbnCode').val()) {
                return true;
            }
        }
    }
}

//更新
$('.update').click(function(){
        const update = {
        id: $(this).data('id'),
        page: $(this).prev().val(),
        pageCount: $(this).parent().prev().text().trim()
        }
        const data = update.page / update.pageCount * 100;
        const progress = data.toFixed(1);
        $(this).parent().next().text(progress + '%');
        $.ajax({
        url: 'http://localhost:8080/MyBooks/members/update',
        type: 'GET',
        data: update
        })
        .done(function(res){
        console.log("更新成功");
        })                    	
        .fail(function(){
        console.log("更新失敗");
        });
});

//読了
$('.finished').click(function(){
        const close = {
        id: $(this).data('id'),
        }
        $(this).parents('tbody').remove();

        $.ajax({
        url: 'http://localhost:8080/MyBooks/members/finished',
        type: 'GET',
        data: close
        })
        .done(function(res){
        console.log("削除成功");
        })                    	
        .fail(function(){
        console.log("削除失敗");
        });
});

// 現在進行中の本のみ表示する
$('#readingBooks').click(function(){
    const readingPage = document.getElementsByClassName('readingPage');
    // ブックマークのクラス属性を使って現在進行中か否かを判断する
    for (let i = 0; i < readingPage.length; i++){
        if (Number(readingPage[i].value) === 0) {
            //ブックマークの位置が0なら非表示
            $('.record' + i).css('display','none');
            $('#readingBooks').css('display','none');
            $('#allBooks').css('display','inline');
        }
    }
    console.log('現在進行中表示完了');
});

// すべて表示
$('#allBooks').click(function(){
    $('tr').removeAttr('style');
$('#allBooks').css('display','none');
    $('#readingBooks').removeAttr('style');
    console.log('すべて表示完了');
});

// 未実装！ブックマークを降順でソート
$('#sortDesc').click(function(){
    $('#sortDesc').css('display','none');
    $('#sortAsc').css('display','inline');
});

// 未実装！ブックマークを昇順でソート
$('#sortAsc').click(function(){
    $('#sortAsc').css('display','none');
    $('#sortDesc').css('display','inline');
});
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import domain.Book;

public class BookDaoImpl implements BookDao{
	//フィールド
	DataSource ds;
	
	//コンストラクター
	BookDaoImpl(DataSource ds){
		this.ds = ds;
	}
	
	//メソッド
	@Override
	public void insert(Book book) throws Exception {
		try(Connection con = ds.getConnection()){
			
			//SQL文の生成
			String sql = "insert into books values ("
					+ "NULL,?,?,?,?,?,?,?,?)";
			//SQL文の実行準備
			PreparedStatement stmt = con.prepareStatement(sql);
			String strDes = book.getDescription();
			//長い概要をカットする
			if (strDes.length() > 511) {
				StringBuilder d = new StringBuilder(strDes);
				d = d.delete(511,d.length());
				strDes = d.replace(d.length() - 1,d.length(),"…").toString();
			}
			stmt.setObject(1,book.getUserId(),Types.INTEGER);
			stmt.setString(2,book.getTitle());
			stmt.setString(3,book.getAuthors());
			stmt.setObject(4,book.getPageCount(),Types.INTEGER);
			stmt.setString(5,strDes);
			stmt.setString(6,book.getCover());
			stmt.setObject(7,book.getIsbn());
			stmt.setObject(8,book.getBookmark(),Types.INTEGER);
			
			//SQL文の実行
			stmt.executeUpdate();
		}catch (Exception e){
			throw e;
		}
	}

	@Override
	public void update(Integer id ,Integer bookmark) throws Exception {
		// try-catch コネクションを確立
		try (Connection con = ds.getConnection()){
			// SQL文のひな形を作成
			String sql = "UPDATE books SET bookmark=? WHERE id=?";
			// SQL文の準備
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, bookmark);
			stmt.setInt(2, id);
			//SQL文の実行
			stmt.executeUpdate();
		} catch (Exception e) {
			throw e;
		}
	}

	@Override
	public void delete(Integer id) throws Exception {
		// try-catch コネクションを確立
		try (Connection con = ds.getConnection()) {
			// SQL文テンプレートの作成
			String sql = "DELETE FROM books WHERE id=?";
			// SQL文の準備
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, id);
			// SQL文の実行
			stmt.executeUpdate();
		}catch (Exception e) {
			throw e;
		}
	}

	@Override
	public Book select(Integer id) throws Exception {
		/*渡されたidを元にDBを検索する
		 *ShowBookListのdoGETから呼び出し
		*/
		Book book = new Book();
		try (Connection con = ds.getConnection()) {
			//SQL文を作成して実行
			String sql = "SELECT * FROM books WHERE user_id=?";
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, id);
			ResultSet rs = stmt.executeQuery();
			
			//検索結果をDTOにマッピングする
			while (rs.next()) {

			}
		} catch (Exception e) {
			throw e;
		}
		
		//DTOを返す
		return book;
	}

	@Override
	public List<Book> findById(Integer id) throws Exception {
		List<Book> bookList = new ArrayList<>();
		try (Connection con = ds.getConnection()) {
			String sql = "SELECT * FROM books WHERE user_id = ? "
					+ "ORDER BY id DESC";
			PreparedStatement stmt = con.prepareStatement(sql);
			// FIXME ユーザIDベタ打ち修正必須
			stmt.setObject(1, id);
			ResultSet rs = stmt.executeQuery();
			while (rs.next()) {
				bookList.add(mapToBook(rs));
			}
		} catch (Exception e) {
			throw e;
		}
		return bookList;
	}
	
	private Book mapToBook(ResultSet rs) {
		Book book = new Book();
		try {
			book.setId(rs.getInt("id"));
			book.setUserId(rs.getInt("user_id"));
			book.setTitle(rs.getString("title"));
			book.setAuthors(rs.getString("authors"));
			book.setPageCount(rs.getInt("page_count"));
			book.setDescription(rs.getString("description"));
			book.setCover(rs.getString("cover"));
			book.setIsbn(rs.getString("isbn"));
			book.setBookmark(rs.getInt("bookmark"));		
		} catch (Exception e) {
			e.printStackTrace();
		}
		return book;
	}
}

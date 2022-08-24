package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Types;

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
					+ "?,?,?,?,?,?,?,?)";
			//SQL文の実行準備
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setObject(1,book.getUserId(),Types.INTEGER);
			stmt.setString(2,book.getTitle());
			stmt.setString(3,book.getAuthors());
			stmt.setObject(4,book.getPageCount(),Types.INTEGER);
			stmt.setString(5,book.getDescription());
			stmt.setString(6,book.getCover());
			stmt.setObject(7,book.getIsbn(),Types.INTEGER);
			stmt.setObject(8,book.getReadPage(),Types.INTEGER);
			//SQL分の実行
			stmt.executeUpdate();
		}catch (Exception e){
			throw e;
		}
	}

	@Override
	public void update(Book book) throws Exception {
		// TODO 自動生成されたメソッド・スタブ
		
	}

	@Override
	public void delete(Book book) throws Exception {
		// TODO 自動生成されたメソッド・スタブ
		
	}

	@Override
	public Book select(Book book) throws Exception {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}
	
}

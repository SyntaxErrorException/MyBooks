package dao;

import java.util.List;

import domain.Book;

public interface BookDao {
	void insert(Book book) throws Exception;

	void update(Book book) throws Exception;

	void delete(Book book) throws Exception;

	Book select(Integer id) throws Exception;

	List<Book> findById(Integer id) throws Exception;
}

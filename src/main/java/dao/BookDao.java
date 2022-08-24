package dao;

import domain.Book;

public interface BookDao {
	void insert(Book book) throws Exception;

	void update(Book book) throws Exception;

	void delete(Book book) throws Exception;

	Book select(Book book) throws Exception;
}

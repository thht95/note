Quy trình commit code
1. git co -b DEV-xxxx
2. git pl origin master
3. git ps origin DEV-xxxx
3* Gửi PR

4. Lên chatwork group "Code Review for Vietnam" yêu cầu 1 ai đó check cái PR của mình 
4.1 vào link ticket: "https://pixta.backlog.jp/view/DEV-xxxx" và điền link của PR của mình
4.2 Self test trên môi trường review: "http://dev-xxxx.review.pixta.jp/"
4.3 vào chatwork group "Overseas Advance" or Slack nhờ test và sau khi họ test xong PHẢI yêu cầu họ đổi trạng thái của UA 

5. Sau khi được LGTM và trạng thái UA là Accepted thì có thể merge
6. Ngày hôm sau, check release channel trên chatwork, khi nào có commit của mình thì test lại trên môi trường production
7. Sau khi đã self test trên production thì yêu cầu người tạo ticket vào check lại và đổi trạng thái của ticket thành closed

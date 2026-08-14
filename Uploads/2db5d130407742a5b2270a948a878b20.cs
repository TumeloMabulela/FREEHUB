public static void MarkMessagesAsRead(int currentUserId, int senderUserId, int? projectId = null)
{
    // Updated query omitting 'readTimestamp = GETDATE()'
    string query = @"
        UPDATE dbo.Message 
        SET status = 'Read' 
        WHERE receiverID = @CurrentUserID 
          AND senderID = @SenderID 
          AND status != 'Read'";

    if (projectId.HasValue && projectId.Value > 0)
    {
        query += " AND projectID = @ProjectID";
        ExecuteNonQuery(query, 
            new SqlParameter("@CurrentUserID", currentUserId), 
            new SqlParameter("@SenderID", senderUserId), 
            new SqlParameter("@ProjectID", projectId.Value));
    }
    else
    {
        ExecuteNonQuery(query, 
            new SqlParameter("@CurrentUserID", currentUserId), 
            new SqlParameter("@SenderID", senderUserId));
    }
}

--------------------------------
-- @module CCPomelo
-- @extend Ref
-- @parent_module pomelo

--------------------------------
-- 
-- @function [parent=#CCPomelo] getState 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] disconnect 
-- @param self
-- @return CCPomelo#CCPomelo self (return value: CCPomelo)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] request 
-- @param self
-- @param #int id
-- @param #char route
-- @param #char msg
-- @return CCPomelo#CCPomelo self (return value: CCPomelo)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] cleanup 
-- @param self
-- @return CCPomelo#CCPomelo self (return value: CCPomelo)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] getArray 
-- @param self
-- @param #array_table table
-- @return array_table#array_table ret (return value: array_table)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] connect 
-- @param self
-- @param #char host
-- @param #int port
-- @return CCPomelo#CCPomelo self (return value: CCPomelo)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] getTable 
-- @param self
-- @param #map_table table
-- @return map_table#map_table ret (return value: map_table)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] requestCallBack 
-- @param self
-- @param #pc_request_s req
-- @param #int rc
-- @param #char resp
-- @return CCPomelo#CCPomelo self (return value: CCPomelo)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] eventCallBack 
-- @param self
-- @param #pc_client_s client
-- @param #int ev_type
-- @param #void ex_data
-- @param #char route
-- @param #char msg
-- @return CCPomelo#CCPomelo self (return value: CCPomelo)
        
--------------------------------
-- 
-- @function [parent=#CCPomelo] getInstance 
-- @param self
-- @return CCPomelo#CCPomelo ret (return value: CCPomelo)
        
return nil

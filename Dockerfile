FROM alpine:3.16.2

COPY ./dist/ .

RUN chmod a+x add2vals

CMD ["./add2vals", "1", "2"]